//
//  RealmRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RealmSwift

open class RealmRepositorySync<DataModelType, ExternalDataFetchType: RepositorySyncExternalDataFetchInterface, RealmObjectType: IdentifiableRealmObject> {
          
    private let externalDataFetch: ExternalDataFetchType
    private let realmDatabase: RealmDatabase
    private let dataModelMapping: any RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, RealmObjectType>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(externalDataFetch: ExternalDataFetchType, realmDatabase: RealmDatabase, dataModelMapping: any RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, RealmObjectType>) {
        
        self.externalDataFetch = externalDataFetch
        self.realmDatabase = realmDatabase
        self.dataModelMapping = dataModelMapping
    }
    
    public var numberOfCachedObjects: Int {
        return getNumberOfCachedObjects()
    }
    
    public func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        return observeRealmCollectionChangesPublisher(
            observeOnRealm: realmDatabase.openRealm()
        )
    }
    
    public func getCachedObject(id: String) -> DataModelType? {
        return getCachedObjectToDataModel(primaryKey: id)
    }
    
    public func getCachedObjects(ids: [String]) -> [DataModelType] {
        return getCachedObjects(
            databaseQuery: RealmDatabaseQuery.filter(
                filter: NSPredicate(format: "id IN %@", ids)
            )
        )
    }
    
    public func getCachedObjects(databaseQuery: RealmDatabaseQuery? = nil) -> [DataModelType] {
        return getCachedObjectsToDataModels(databaseQuery: databaseQuery)
    }
}

// MARK: - Cache

extension RealmRepositorySync {
    
    private func getNumberOfCachedObjects(databaseQuery: RealmDatabaseQuery? = nil) -> Int {
        return getCachedResults(realm: realmDatabase.openRealm(), databaseQuery: databaseQuery).count
    }
    
    private func getCachedResults(realm: Realm, databaseQuery: RealmDatabaseQuery?) -> Results<RealmObjectType> {
        
        let results = realm.objects(RealmObjectType.self)
        
        if let filter = databaseQuery?.filter {
            return results
                .filter(filter)
        }
        else if let filter = databaseQuery?.filter, let sortByKeyPath = databaseQuery?.sortByKeyPath {
            return results
                .filter(filter)
                .sorted(byKeyPath: sortByKeyPath.keyPath, ascending: sortByKeyPath.ascending)
        }
        
        return results
    }
    
    private func getCachedObjectsToDataModels(databaseQuery: RealmDatabaseQuery?) -> [DataModelType] {
        let dataModels: [DataModelType] = getCachedResults(realm: realmDatabase.openRealm(), databaseQuery: databaseQuery).compactMap {
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

extension RealmRepositorySync {
    
    private func fetchExternalObjects(getObjectsType: RepositorySyncGetObjectsType, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<ExternalDataFetchType.DataModel>, Never>  {
        
        switch getObjectsType {
        case .allObjects:
            return externalDataFetch
                .getObjectsPublisher(requestPriority: requestPriority)
                .eraseToAnyPublisher()
            
        case .object(let id):
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
    
    public func storeExternalDataFetchResponse(response: RepositorySyncResponse<ExternalDataFetchType.DataModel>, updatePolicy: Realm.UpdatePolicy = .modified) -> RepositorySyncResponse<DataModelType> {
                
        let realm: Realm = realmDatabase.openRealm()
        
        let objectsToAdd: [RealmObjectType] = response.objects.compactMap {
            self.dataModelMapping.toPersistObject(externalObject: $0)
        }
        
        let errors: [Error]
        
        do {
            
            try realm.write {
                realm.add(objectsToAdd, update: updatePolicy)
            }
            
            errors = Array()
        }
        catch let error {
            errors = [error]
        }
        
        return RepositorySyncResponse<DataModelType>(
            objects: response.objects.compactMap { self.dataModelMapping.toDataModel(externalObject: $0) },
            errors: errors
        )
    }
    
    public func syncExternalDataFetchResponse(response: RepositorySyncResponse<ExternalDataFetchType.DataModel>, updatePolicy: Realm.UpdatePolicy = .modified) -> RepositorySyncResponse<DataModelType> {

        let shouldDeleteObjectsNotFoundInResponse: Bool = true
        
        let realm: Realm = realmDatabase.openRealm()

        var responseDataModels: [DataModelType] = Array()
        
        var objectsToAdd: [RealmObjectType] = Array()
        // store all objects in the collection
        var objectsToRemove: [RealmObjectType] = Array(realm.objects(RealmObjectType.self))
        
        for externalObject in response.objects {

            if let dataModel = dataModelMapping.toDataModel(externalObject: externalObject) {
                responseDataModels.append(dataModel)
            }
            
            if let realmObject = dataModelMapping.toPersistObject(externalObject: externalObject) {
                
                objectsToAdd.append(realmObject)
                
                // added realm object can be removed from this list so it won't be deleted from realm
                if shouldDeleteObjectsNotFoundInResponse, let realmObjectIndex = objectsToRemove.firstIndex(where: { $0.id == realmObject.id }) {
                    objectsToRemove.remove(at: realmObjectIndex)
                }
            }
        }

        let errors: [Error]
        
        do {
            try realm.write {
                
                realm.add(objectsToAdd, update: updatePolicy)
               
                if shouldDeleteObjectsNotFoundInResponse, objectsToRemove.count > 0 {
                    realm.delete(objectsToRemove)
                }
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

extension RealmRepositorySync {
    
    private func getCachedDataModelsByGetObjectsType(getObjectsType: RepositorySyncGetObjectsType) -> [DataModelType] {
        
        let dataModels: [DataModelType]
        
        switch getObjectsType {
        
        case .allObjects:
            dataModels = getCachedObjectsToDataModels(databaseQuery: nil)
            
        case .object(let id):
            if let dataModel = getCachedObjectToDataModel(primaryKey: id) {
                dataModels = [dataModel]
            }
            else {
                dataModels = []
            }
        }
        
        return dataModels
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: RepositorySyncGetObjectsType) -> RepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = getCachedDataModelsByGetObjectsType(
            getObjectsType: getObjectsType
        )
        
        let response = RepositorySyncResponse<DataModelType>(
            objects: dataModels,
            errors: []
        )
        
        return response
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponsePublisher(getObjectsType: RepositorySyncGetObjectsType) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        return Just(getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: getObjectsType))
            .eraseToAnyPublisher()
    }
    
    // TODO: Questions, Unknowns, Etc.
    /*
        - Is there a better way to setup RepositorySyncMapping?  I couldn't get it to work with a protocol and associated types. Not sure I like the open class because there isn't an explicit way to force subclasses to override parent methods.
        - Can we observe a specific realm object and only trigger when there are actual changes? (https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/react-to-changes/)
        - How do we handle more complex external data fetching?  For instance, a url request could contain query parameters and http body. Do we force that on subclasses of repository sync?  Do we provide methods for subclasses to hook into for observing, pushing data models for syncing, etc?
        -
     */
    
    public func getObjectsPublisher(getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, updatePolicy: Realm.UpdatePolicy = .modified) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
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
                    getObjectsType: getObjectsType
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
                        getObjectsType: getObjectsType
                    )
                }
                .eraseToAnyPublisher()
            }
            else {
               
                return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
                    getObjectsType: getObjectsType
                )
                .eraseToAnyPublisher()
            }
        
        case .returnCacheDataElseFetch(let requestPriority, let observeChanges):
            
            if observeChanges {
                        
                let numberOfRealmObjects: Int = getCachedResults(realm: realm, databaseQuery: nil).count
                
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
                        getObjectsType: getObjectsType
                    )
                }
                .eraseToAnyPublisher()
            }
            else {
                
                if getNumberOfCachedObjects() == 0 {
                    
                    return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority,
                        updatePolicy: updatePolicy
                    )
                    .map { (response: RepositorySyncResponse<DataModelType>) in
                    
                        let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
                            getObjectsType: getObjectsType
                        )
                        
                        return response.copy(objects: dataModels)
                    }
                    .eraseToAnyPublisher()
                }
                else {
                    
                    return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
                        getObjectsType: getObjectsType
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
                    getObjectsType: getObjectsType
                )
            }
            .eraseToAnyPublisher()
        }
    }
}

