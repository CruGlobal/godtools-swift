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
    
    private func getNumberOfCachedObjects(filter: NSPredicate?) -> Int {
        return getCachedResults(realm: realmDatabase.openRealm(), filter: filter).count
    }
    
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
    
    private func observeRealmCollectionChangesPublisher(observeOnRealm: Realm) -> AnyPublisher<Void, Never> {
                
        return observeOnRealm
            .objects(RealmObjectType.self)
            .objectWillChange
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    private func getCachedObjectToDataModel(primaryKey: String) -> DataModelType? {
        
        let realm: Realm = realmDatabase.openRealm()
        let realmObject: RealmObjectType? = realm.object(ofType: RealmObjectType.self, forPrimaryKey: primaryKey)
        
        guard let realmObject = realmObject, let dataModel = dataModelMapping.toDataModel(persistObject: realmObject) else {
            return nil
        }
        
        return dataModel
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
        
        let realm: Realm = realmDatabase.openRealm()
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
    
    private func getCachedDataModelsByGetObjectsType(getObjectsType: RepositorySyncGetObjectsType, filter: NSPredicate?) -> [DataModelType] {
        
        let dataModels: [DataModelType]
        
        switch getObjectsType {
        
        case .objects:
            dataModels = getCachedObjectsToDataModels(filter: filter)
        
        case .objectId(let id):
            if let dataModel = getCachedObjectToDataModel(primaryKey: id) {
                dataModels = [dataModel]
            }
            else {
                dataModels = []
            }
        }
        
        return dataModels
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: RepositorySyncGetObjectsType, filter: NSPredicate?) -> RepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = getCachedDataModelsByGetObjectsType(
            getObjectsType: getObjectsType,
            filter: filter
        )
        
        let response = RepositorySyncResponse<DataModelType>(
            objects: dataModels,
            errors: []
        )
        
        return response
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponsePublisher(getObjectsType: RepositorySyncGetObjectsType, filter: NSPredicate?) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        return Just(getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: getObjectsType, filter: filter))
            .eraseToAnyPublisher()
    }
    
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
            .map { (response: RepositorySyncResponse<DataModelType>) in
            
                let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
                    getObjectsType: getObjectsType,
                    filter: filter
                )
                
                return response.copy(objects: dataModels)
            }
            .eraseToAnyPublisher()
            
        case .returnCacheDataDontFetch(let observeChanges):
            
            if observeChanges {
               
                return observeRealmCollectionChangesPublisher(
                    observeOnRealm: realm
                )
                .map { (onChange: Void) in
                    
                    return self.getCachedDataModelsByGetObjectsTypeToResponse(
                        getObjectsType: getObjectsType,
                        filter: filter
                    )
                }
                .eraseToAnyPublisher()
            }
            else {
               
                return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
                    getObjectsType: getObjectsType,
                    filter: filter
                )
                .eraseToAnyPublisher()
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
                
                return observeRealmCollectionChangesPublisher(
                    observeOnRealm: realm
                )
                .map { (onChange: Void) in
                    
                    return self.getCachedDataModelsByGetObjectsTypeToResponse(
                        getObjectsType: getObjectsType,
                        filter: filter
                    )
                }
                .eraseToAnyPublisher()
            }
            else {
                
                if getNumberOfCachedObjects(filter: filter) == 0 {
                    
                    return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority,
                        updatePolicy: updatePolicy
                    )
                    .map { (response: RepositorySyncResponse<DataModelType>) in
                    
                        let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
                            getObjectsType: getObjectsType,
                            filter: filter
                        )
                        
                        return response.copy(objects: dataModels)
                    }
                    .eraseToAnyPublisher()
                }
                else {
                    
                    return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
                        getObjectsType: getObjectsType,
                        filter: filter
                    )
                    .eraseToAnyPublisher()
                }
            }
        
        case .returnCacheDataAndFetch(let requestPriority):
            
            makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                getObjectsType: getObjectsType,
                requestPriority: requestPriority,
                updatePolicy: updatePolicy
            )
            
            return observeRealmCollectionChangesPublisher(
                observeOnRealm: realm
            )
            .map { (onChange: Void) in
                
                return self.getCachedDataModelsByGetObjectsTypeToResponse(
                    getObjectsType: getObjectsType,
                    filter: filter
                )
            }
            .eraseToAnyPublisher()
        }
    }
}
