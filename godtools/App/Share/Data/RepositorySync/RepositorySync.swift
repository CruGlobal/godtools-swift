//
//  RepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RealmSwift

open class RepositorySync<DataModelType, ExternalDataFetchType: RepositorySyncExternalDataFetchInterface, RealmObjectType: Object> {
      
    private let externalDataFetch: ExternalDataFetchType
    private let realmDatabase: RealmDatabase
    private let dataModelMapping: RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, RealmObjectType>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(externalDataFetch: ExternalDataFetchType, realmDatabase: RealmDatabase, dataModelMapping: RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, RealmObjectType>) {
        
        self.externalDataFetch = externalDataFetch
        self.realmDatabase = realmDatabase
        self.dataModelMapping = dataModelMapping
    }

    private func mapExternalObjectsToDataModels(externalObjects: [ExternalDataFetchType.DataModel]) -> [DataModelType] {
        return externalObjects.compactMap {
            self.dataModelMapping.toDataModel(externalObject: $0)
        }
    }
    
    func getObjectPublisher(id: String, cachePolicy: RepositorySyncCachePolicy, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        print("\n get object publisher")
        print("  id: \(id)")
        print("  cache policy: \(cachePolicy)")
        
        externalDataFetch
            .getObjectPublisher(id: id, requestPriority: requestPriority)
            .flatMap({ (response: RepositorySyncResponse<ExternalDataFetchType.DataModel>) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> in
                
                let dataModels: [DataModelType] = self.mapExternalObjectsToDataModels(
                    externalObjects: response.objects
                )
                
                return self.realmDatabase.writeObjectsPublisher { (realm: Realm) in
                    
                    let realmObjects: [RealmObjectType] = dataModels.compactMap {
                        self.dataModelMapping.toPersistObject(dataModel: $0)
                    }
                    
                    return realmObjects
                    
                } mapInBackgroundClosure: { (objects: [RealmObjectType]) in
                    
                    return dataModels
                }
                .map { (dataModels: [DataModelType]) in
                    
                    return RepositorySyncResponse<DataModelType>(
                        objects: dataModels
                    )
                }
                .catch { (error: Error) in
                    
                    let response: RepositorySyncResponse<DataModelType> = RepositorySyncResponse(
                        objects: Array<DataModelType>()
                    )
                    
                    return Just(response)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            })
            .sink { (response: RepositorySyncResponse<DataModelType>) in
                
                print("\n DID SINK data models: \(response.objects)")
            }
            .store(in: &cancellables)
        
        return realmDatabase
            .openRealm()
            .objects(RealmObjectType.self)
            .objectWillChange
            .map { _ in
                return RepositorySyncResponse(objects: [])
            }
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(cachePolicy: RepositorySyncCachePolicy, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        return Just(RepositorySyncResponse(objects: []))
            .eraseToAnyPublisher()
    }
}
