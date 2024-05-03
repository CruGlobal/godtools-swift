//
//  RealmDatabase+Read.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

extension RealmDatabase {
    
    func readObjectElseCreateNew<T: IdentifiableRealmObject>(realm: Realm, primaryKey: String) -> T {
        
        let object: T
        
        if let existingObject = realm.object(ofType: T.self, forPrimaryKey: primaryKey) {
            object = existingObject
        }
        else {
            object = T()
            object.id = primaryKey
        }
        
        return object
    }
    
    func readObject<T: Object>(realm: Realm, primaryKey: String) -> T? {
        
        let realmObject: T? = realm.object(ofType: T.self, forPrimaryKey: primaryKey)
        
        return realmObject
    }
    
    func readObject<T: Object>(primaryKey: String) -> T? {
          
        let realm: Realm = openRealm()
        
        return readObject(realm: realm, primaryKey: primaryKey)
    }
    
    func readObjectInBackground<T: Object>(primaryKey: String, completion: @escaping ((_ object: T?) -> Void)) {
        
        background { realm in
            
            let realmObject: T? = self.readObject(realm: realm, primaryKey: primaryKey)

            completion(realmObject)
        }
    }
    
    func readObjectPublisher<T: Object>(primaryKey: String) -> AnyPublisher<T?, Never> {
        
        return Future() { promise in
            
            self.readObjectInBackground(primaryKey: primaryKey) { (realmObject: T?) in
                
                promise(.success(realmObject))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Read Objects

extension RealmDatabase {
    
    func readObjects<T: Object>(realm: Realm) -> Results<T> {
        return realm.objects(T.self)
    }
    
    func readObjects<T: Object>() -> Results<T> {
          
        let realm: Realm = openRealm()
        
        return readObjects(realm: realm)
    }
    
    func readObjectsInBackground<T: Object>(completion: @escaping ((_ results: Results<T>) -> Void)) {
        
        background { realm in
            
            let results: Results<T> = self.readObjects(realm: realm)

            completion(results)
        }
    }
    
    func readObjectsPublisher<T: Object>() -> AnyPublisher<Results<T>, Never> {
        
        return Future() { promise in
            
            self.readObjectsInBackground() { (results: Results<T>) in
                
                promise(.success(results))
            }
        }
        .eraseToAnyPublisher()
    }
}
