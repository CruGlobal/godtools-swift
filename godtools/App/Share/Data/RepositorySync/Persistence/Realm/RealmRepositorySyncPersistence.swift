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
    
    private let realmDatabase: RealmDatabase
    private let dataModelMapping: RealmRepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>
    
    init(realmDatabase: RealmDatabase, dataModelMapping: RealmRepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>) {
        
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
    
    func getCount() -> Int {
        
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
        
        let filter = NSPredicate(format: "id IN %@", ids)
        
        let query = RealmDatabaseQuery.filter(filter: filter)
        
        return getObjects(query: query)
    }
    
    private func getNumberObjects(query: RealmDatabaseQuery?) -> Int {
        
        return getPersistedObjects(realm: realmDatabase.openRealm(), query: query).count
    }
    
    private func getPersistedObjects(realm: Realm, query: RealmDatabaseQuery?) -> Results<PersistObjectType> {
        
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
