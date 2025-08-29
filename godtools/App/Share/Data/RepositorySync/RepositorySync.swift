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

open class RepositorySync<DataModelType, ExternalDataFetchType: RepositorySyncExternalDataFetchInterface, RealmObjectType: IdentifiableRealmObject> {
      
    private let externalDataFetch: ExternalDataFetchType
    private let realmDatabase: RealmDatabase
    private let dataModelMapping: RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, RealmObjectType>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(externalDataFetch: ExternalDataFetchType, realmDatabase: RealmDatabase, dataModelMapping: RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, RealmObjectType>) {
        
        self.externalDataFetch = externalDataFetch
        self.realmDatabase = realmDatabase
        self.dataModelMapping = dataModelMapping
    }
}

// MARK: - Cache

extension RepositorySync {
    
    func getCachedResults(realm: Realm) -> Results<RealmObjectType> {
        return realm.objects(RealmObjectType.self)
    }
    
    func getCachedObjectsToDataModels() -> [DataModelType] {
        let dataModels: [DataModelType] = getCachedResults(realm: realmDatabase.openRealm()).compactMap {
            self.dataModelMapping.toDataModel(persistObject: $0)
        }
        return dataModels
    }
    
    func getCachedObjectsToDataModelsPublisher() -> AnyPublisher<[DataModelType], Never> {
        let dataModels: [DataModelType] = getCachedObjectsToDataModels()
        return Just(dataModels)
            .eraseToAnyPublisher()
    }
    
    func getCachedObjectsToResponse() -> RepositorySyncResponse<DataModelType> {
        let dataModels: [DataModelType] = getCachedResults(realm: realmDatabase.openRealm()).compactMap {
            self.dataModelMapping.toDataModel(persistObject: $0)
        }
        return RepositorySyncResponse(
            objects: dataModels,
            errors: []
        )
    }
    
    func getCachedObjectsToResponsePublisher() -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        let response: RepositorySyncResponse<DataModelType> = getCachedObjectsToResponse()
        return Just(response)
            .eraseToAnyPublisher()
    }
    
    private func fetchCachedObjectsAndObserveChangesPublisher(realm: Realm) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        return realm
            .objects(RealmObjectType.self)
            .objectWillChange
            .map { _ in
                return self.getCachedObjectsToResponse()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - External Data Fetch

extension RepositorySync {
    
    private func makeSinkingfetchAndStoreObjectsFromExternalDataFetch(requestPriority: RequestPriority) {
        
        fetchAndStoreObjectsFromExternalDataFetchPublisher(
            requestPriority: requestPriority
        )
        .sink { (response: RepositorySyncResponse<DataModelType>) in
            
        }
        .store(in: &cancellables)
    }
    
    private func fetchAndStoreObjectsFromExternalDataFetchPublisher(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        return externalDataFetch
            .getObjectsPublisher(requestPriority: requestPriority)
            .map { (getObjectsResponse: RepositorySyncResponse<ExternalDataFetchType.DataModel>) in
                
                let responseDataModels: [DataModelType] = getObjectsResponse.objects.compactMap {
                    self.dataModelMapping.toDataModel(externalObject: $0)
                }
                
                let realmObjects: [RealmObjectType] = responseDataModels.compactMap {
                    self.dataModelMapping.toPersistObject(dataModel: $0)
                }
                
                let realm: Realm = self.realmDatabase.openRealm()
                let errors: [Error]
                
                do {
                    try realm.write {
                        realm.add(realmObjects, update: .all)
                    }
                    
                    errors = Array()
                }
                catch let error {
                    errors = [error]
                }
                
                let response = RepositorySyncResponse(
                    objects: responseDataModels,
                    errors: errors
                )
                
                return response
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Objects

extension RepositorySync {
    
    func getObjectsPublisher(cachePolicy: RepositorySyncCachePolicy) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        let realm: Realm = realmDatabase.openRealm()
        
        switch cachePolicy {
            
        case .fetchIgnoringCacheData(let requestPriority, let observeChanges):
            
            if observeChanges {
                
                makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                    requestPriority: requestPriority
                )
                
                return fetchCachedObjectsAndObserveChangesPublisher(
                    realm: realm
                )
                .eraseToAnyPublisher()
            }
            else {
                
                return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                    requestPriority: requestPriority
                )
                .map { _ in
                    return self.getCachedObjectsToResponse()
                }
                .eraseToAnyPublisher()
            }
            
        case .returnCacheDataDontFetch(let observeChanges):
            
            if observeChanges {
               
                return fetchCachedObjectsAndObserveChangesPublisher(
                    realm: realm
                )
                .eraseToAnyPublisher()
            }
            else {
               
                return getCachedObjectsToResponsePublisher()
            }
        
        case .returnCacheDataElseFetch(let requestPriority, let observeChanges):
            
            if observeChanges {
                        
                let numberOfRealmObjects: Int = getCachedResults(realm: realm).count
                
                if numberOfRealmObjects == 0 {
                    
                    makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                        requestPriority: requestPriority
                    )
                }
                
                return fetchCachedObjectsAndObserveChangesPublisher(
                    realm: realm
                )
                .eraseToAnyPublisher()
            }
            else {
                
                let cachedObjects: [DataModelType] = getCachedObjectsToDataModels()
                
                if cachedObjects.isEmpty {
                    
                    return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                        requestPriority: requestPriority
                    )
                    .eraseToAnyPublisher()
                }
                else {
                    
                    let response = RepositorySyncResponse<DataModelType>(
                        objects: cachedObjects,
                        errors: []
                    )
                    
                    return Just(response)
                        .eraseToAnyPublisher()
                }
            }
        
        case .returnCacheDataAndFetch(let requestPriority):
            
            makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                requestPriority: requestPriority
            )
            
            return fetchCachedObjectsAndObserveChangesPublisher(
                realm: realm
            )
            .eraseToAnyPublisher()
        }
    }
}

// MARK: - Object By Id

extension RepositorySync {
    
    private func mapExternalObjectsToDataModels(externalObjects: [ExternalDataFetchType.DataModel]) -> [DataModelType] {
        return externalObjects.compactMap {
            self.dataModelMapping.toDataModel(externalObject: $0)
        }
    }
    
    func getObjectPublisher(id: String, cachePolicy: RepositorySyncCachePolicy, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        // TODO: Questions, Unknowns, Etc.
        /*
            - I think observing should be optional. Either make a flag or separate method?  If in the middle of a combine chain we wouldn't want to observe.
            - Is there a better way to setup RepositorySyncMapping?  I couldn't get it to work with a protocol and associated types. Not sure I like the open class because there isn't an explicit way to force subclasses to override parent methods.
            - Can we observe the specific realm object and only trigger when there are actual changes? (https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/react-to-changes/)
            - How do we handle more complex external data fetching?  For instance, a url request could contain query parameters and http body. Do we force that on subclasses of repository sync?  Do we provide methods for subclasses to hook into for observing, pushing data models for syncing, etc?
            -
         */
        
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
                        objects: dataModels,
                        errors: []
                    )
                }
                .catch { (error: Error) in
                    
                    let response: RepositorySyncResponse<DataModelType> = RepositorySyncResponse(
                        objects: Array<DataModelType>(),
                        errors: []
                    )
                    
                    return Just(response)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            })
            .sink { (response: RepositorySyncResponse<DataModelType>) in
                
            }
            .store(in: &cancellables)
        
        return realmDatabase
            .openRealm()
            .objects(RealmObjectType.self)
            .objectWillChange
            .map { _ in
                return RepositorySyncResponse(objects: [], errors: [])
            }
            .eraseToAnyPublisher()
    }
    
    func observeObjectPublisher(id: String, cachePolicy: RepositorySyncCachePolicy) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        let realmObject: RealmObjectType
        let realm: Realm = realmDatabase.openRealm()
        
        if let existingObject = realm.object(ofType: RealmObjectType.self, forPrimaryKey: id) {
            
            realmObject = existingObject
        }
        else {
            
            realmObject = RealmObjectType()
            realmObject.id = id
            
            _ = realmDatabase.writeObjects(realm: realm) { realm in
                return [realmObject]
            }
        }
        
        realmObject.observe { change in
            
        }
        
        let response = RepositorySyncResponse<DataModelType>(objects: [], errors: [])
        
        return Just(response)
            .eraseToAnyPublisher()
    }
    
    private func observeObjectPublisher(object: RealmObjectType) -> AnyPublisher<Void, Never> {
        
        return Future { promise in
            
            let token = object.observe { change in
                
                promise(.success(Void()))
            }
        }
        .eraseToAnyPublisher()
    }
}
