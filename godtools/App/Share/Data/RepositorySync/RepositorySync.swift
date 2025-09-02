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
    
    private func getCachedResults(realm: Realm, filter: NSPredicate?) -> Results<RealmObjectType> {
        
        let results = realm.objects(RealmObjectType.self)
        
        if let filter = filter {
            return results
                .filter(filter)
        }
        
        return results
    }
    
    private func getCachedObjectsToDataModels(filter: NSPredicate?) -> [DataModelType] {
        let dataModels: [DataModelType] = getCachedResults(realm: realmDatabase.openRealm(), filter: filter).compactMap {
            self.dataModelMapping.toDataModel(persistObject: $0)
        }
        return dataModels
    }
    
    private func getCachedObjectsToDataModelsPublisher(filter: NSPredicate?) -> AnyPublisher<[DataModelType], Never> {
        let dataModels: [DataModelType] = getCachedObjectsToDataModels(filter: filter)
        return Just(dataModels)
            .eraseToAnyPublisher()
    }
    
    private func getCachedObjectsToResponse(filter: NSPredicate?) -> RepositorySyncResponse<DataModelType> {
        let dataModels: [DataModelType] = getCachedResults(realm: realmDatabase.openRealm(), filter: filter).compactMap {
            self.dataModelMapping.toDataModel(persistObject: $0)
        }
        return RepositorySyncResponse(
            objects: dataModels,
            errors: []
        )
    }
    
    private func getCachedObjectsToResponsePublisher(filter: NSPredicate?) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        let response: RepositorySyncResponse<DataModelType> = getCachedObjectsToResponse(filter: filter)
        return Just(response)
            .eraseToAnyPublisher()
    }
    
    private func fetchCachedObjectsAndObserveChangesPublisher(realm: Realm, filter: NSPredicate?) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        return realm
            .objects(RealmObjectType.self)
            .objectWillChange
            .map { _ in
                return self.getCachedObjectsToResponse(filter: filter)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - External Data Fetch

extension RepositorySync {
    
    private func fetchExternalObjects(getObjectsType: RepositorySyncGetObjectsType, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<ExternalDataFetchType.DataModel>, Never>  {
        
        switch getObjectsType {
        case .objects:
            return externalDataFetch
                .getObjectsPublisher(requestPriority: requestPriority)
                .eraseToAnyPublisher()
            
        case .objectId(let id):
            return externalDataFetch
                .getObjectPublisher(id: id, requestPriority: requestPriority)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeSinkingfetchAndStoreObjectsFromExternalDataFetch(getObjectsType: RepositorySyncGetObjectsType, requestPriority: RequestPriority, updatePolicy: Realm.UpdatePolicy) {
        
        fetchAndStoreObjectsFromExternalDataFetchPublisher(
            getObjectsType: getObjectsType,
            requestPriority: requestPriority,
            updatePolicy: updatePolicy
        )
        .sink { (response: RepositorySyncResponse<DataModelType>) in
            
        }
        .store(in: &cancellables)
    }
    
    private func fetchAndStoreObjectsFromExternalDataFetchPublisher(getObjectsType: RepositorySyncGetObjectsType, requestPriority: RequestPriority, updatePolicy: Realm.UpdatePolicy) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        return fetchExternalObjects(getObjectsType: getObjectsType, requestPriority: requestPriority)
            .map { (getObjectsResponse: RepositorySyncResponse<ExternalDataFetchType.DataModel>) in
                return self.storeExternalDataFetchResponse(
                    response: getObjectsResponse,
                    updatePolicy: updatePolicy
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func storeExternalDataFetchResponse(response: RepositorySyncResponse<ExternalDataFetchType.DataModel>, updatePolicy: Realm.UpdatePolicy) -> RepositorySyncResponse<DataModelType> {
        
        let responseDataModels: [DataModelType] = response.objects.compactMap {
            self.dataModelMapping.toDataModel(externalObject: $0)
        }
        
        let realmObjects: [RealmObjectType] = responseDataModels.compactMap {
            self.dataModelMapping.toPersistObject(dataModel: $0)
        }
        
        let realm: Realm = self.realmDatabase.openRealm()
        let errors: [Error]
        
        do {
            try realm.write {
                realm.add(realmObjects, update: updatePolicy)
            }
            
            errors = Array()
        }
        catch let error {
            errors = [error]
        }
        
        return RepositorySyncResponse<DataModelType>(
            objects: responseDataModels,
            errors: errors
        )
    }
}

// MARK: - Get Objects

extension RepositorySync {
    
    // TODO: Questions, Unknowns, Etc.
    /*
        - Is there a better way to setup RepositorySyncMapping?  I couldn't get it to work with a protocol and associated types. Not sure I like the open class because there isn't an explicit way to force subclasses to override parent methods.
        - Can we observe a specific realm object and only trigger when there are actual changes? (https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/react-to-changes/)
        - How do we handle more complex external data fetching?  For instance, a url request could contain query parameters and http body. Do we force that on subclasses of repository sync?  Do we provide methods for subclasses to hook into for observing, pushing data models for syncing, etc?
        -
     */
    
    func getObjectsPublisher(getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, filter: NSPredicate? = nil, updatePolicy: Realm.UpdatePolicy = .modified) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        let realm: Realm = realmDatabase.openRealm()
        
        switch cachePolicy {
            
        case .fetchIgnoringCacheData(let requestPriority):
            
            return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                getObjectsType: getObjectsType,
                requestPriority: requestPriority,
                updatePolicy: updatePolicy
            )
            .map { _ in
                return self.getCachedObjectsToResponse(filter: filter)
            }
            .eraseToAnyPublisher()
            
        case .returnCacheDataDontFetch(let observeChanges):
            
            if observeChanges {
               
                return fetchCachedObjectsAndObserveChangesPublisher(
                    realm: realm,
                    filter: filter
                )
                .eraseToAnyPublisher()
            }
            else {
               
                return getCachedObjectsToResponsePublisher(filter: filter)
            }
        
        case .returnCacheDataElseFetch(let requestPriority, let observeChanges):
            
            if observeChanges {
                        
                let numberOfRealmObjects: Int = getCachedResults(realm: realm, filter: filter).count
                
                if numberOfRealmObjects == 0 {
                    
                    makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority,
                        updatePolicy: updatePolicy
                    )
                }
                
                return fetchCachedObjectsAndObserveChangesPublisher(
                    realm: realm,
                    filter: filter
                )
                .eraseToAnyPublisher()
            }
            else {
                
                let cachedObjects: [DataModelType] = getCachedObjectsToDataModels(filter: filter)
                
                if cachedObjects.isEmpty {
                    
                    return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority,
                        updatePolicy: updatePolicy
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
                getObjectsType: getObjectsType,
                requestPriority: requestPriority,
                updatePolicy: updatePolicy
            )
            
            return fetchCachedObjectsAndObserveChangesPublisher(
                realm: realm,
                filter: filter
            )
            .eraseToAnyPublisher()
        }
    }
}
