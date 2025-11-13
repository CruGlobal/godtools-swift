//
//  RealmRepositorySyncPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, PersistObjectType: IdentifiableRealmObject>: RepositorySyncPersistence {
    
    private let dataModelMapping: any RepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>
    
    let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase, dataModelMapping: any RepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>) {
        
        self.realmDatabase = realmDatabase
        self.dataModelMapping = dataModelMapping
    }
}

// MARK: - Observe

extension RealmRepositorySyncPersistence {
    
    func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        
        return observeRealmCollectionChangesPublisher(
            observeOnRealm: realmDatabase.openRealm()
        )
    }
    
    private func observeRealmCollectionChangesPublisher(observeOnRealm: Realm) -> AnyPublisher<Void, Never> {
                
        return observeOnRealm
            .objects(PersistObjectType.self)
            .objectWillChange
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: Read

extension RealmRepositorySyncPersistence {
    
    func getObjectCount() -> Int {
        
        getNumberObjects(query: nil)
    }
    
    func getObject(id: String) -> DataModelType? {
        
        let realm: Realm = realmDatabase.openRealm()
        let realmObject: PersistObjectType? = realm.object(ofType: PersistObjectType.self, forPrimaryKey: id)
        
        guard let realmObject = realmObject, let dataModel = dataModelMapping.toDataModel(persistObject: realmObject) else {
            return nil
        }
        
        return dataModel
    }
    
    func getObjects() -> [DataModelType] {
        
        return getObjects(query: nil)
    }
    
    func getObjects(query: RealmDatabaseQuery? = nil) -> [DataModelType] {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let objects: Results<PersistObjectType> = getPersistedObjects(
            realm: realm,
            query: query
        )
        
        let dataModels: [DataModelType] = objects.compactMap { object in
            self.dataModelMapping.toDataModel(persistObject: object)
        }
        
        return dataModels
    }
    
    func getObjects(ids: [String]) -> [DataModelType] {
                
        let query = RealmDatabaseQuery.filter(filter: getObjectsByIdsFilter(ids: ids))
        
        return getObjects(query: query)
    }
    
    func getNumberObjects(query: RealmDatabaseQuery?) -> Int {
        
        return getPersistedObjects(realm: realmDatabase.openRealm(), query: query).count
    }
    
    private func getObjectsByIdsFilter(ids: [String]) -> NSPredicate {
        return NSPredicate(format: "id IN %@", ids)
    }
    
    func getPersistedObjects(realm: Realm, query: RealmDatabaseQuery?) -> Results<PersistObjectType> {
        
        let results = realm.objects(PersistObjectType.self)
        
        if let filter = query?.filter {
            return results
                .filter(filter)
        }
        else if let filter = query?.filter, let sortByKeyPath = query?.sortByKeyPath {
            return results
                .filter(filter)
                .sorted(byKeyPath: sortByKeyPath.keyPath, ascending: sortByKeyPath.ascending)
        }
        
        return results
    }
}

// MARK: - Write

extension RealmRepositorySyncPersistence {
    
    func writeObjects(externalObjects: [ExternalObjectType], deleteObjectsNotFoundInExternalObjects: Bool) -> [DataModelType] {
                
        let realm: Realm = realmDatabase.openRealm()
        
        var dataModels: [DataModelType] = Array()
        
        var objectsToAdd: [PersistObjectType] = Array()
        
        var objectsToRemove: [PersistObjectType]
        
        if deleteObjectsNotFoundInExternalObjects {
            // store all objects in the collection
            objectsToRemove = Array(getPersistedObjects(realm: realm, query: nil))
        }
        else {
            objectsToRemove = Array()
        }
        
        for externalObject in externalObjects {

            if let dataModel = dataModelMapping.toDataModel(externalObject: externalObject) {
                dataModels.append(dataModel)
            }
            
            if let swiftDataObject = dataModelMapping.toPersistObject(externalObject: externalObject) {
                
                objectsToAdd.append(swiftDataObject)
                
                // added swift data object can be removed from this list so it won't be deleted from swift data
                if deleteObjectsNotFoundInExternalObjects, let index = objectsToRemove.firstIndex(where: { $0.id == swiftDataObject.id }) {
                    objectsToRemove.remove(at: index)
                }
            }
        }
        
        _ = updateObjectsInRealm(
            realm: realm,
            objectsToAdd: objectsToAdd,
            objectsToRemove: objectsToRemove
        )
        
        return dataModels
    }
    
    private func updateObjectsInRealm(realm: Realm, objectsToAdd: [PersistObjectType], objectsToRemove: [PersistObjectType]) -> [Error] {
        
        let errors: [Error]
        
        do {
            
            try realm.write {
                
                realm.add(objectsToAdd, update: .modified)
               
                if objectsToRemove.count > 0 {
                    realm.delete(objectsToRemove)
                }
            }
            
            errors = Array()
        }
        catch let error {
            errors = [error]
        }
        
        return errors
    }
}

// MARK: - Delete

extension RealmRepositorySyncPersistence {
    
    func deleteAllObjects() {
        
        _ = deleteAllObjectsOnRealm()
    }
    
    private func deleteAllObjectsOnRealm() -> Error? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        do {
            try realm.write {
                realm.deleteAll()
            }
            
            return nil
        }
        catch let error {
            return error
        }
    }
}
