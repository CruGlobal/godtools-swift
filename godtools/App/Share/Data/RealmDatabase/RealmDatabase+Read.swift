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

// MARK: - Read Object

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

// MARK: - Read Object With Mapping

extension RealmDatabase {
    
    func readAndMapObjectInBackground<T: Object, U>(primaryKey: String, mapInBackgroundClosure: @escaping ((_ object: T?) -> U?), completion: @escaping ((_ mappedObject: U?) -> Void)) {
        
        background { realm in
            
            let realmObject: T? = self.readObject(realm: realm, primaryKey: primaryKey)
            
            let mappedObject: U? = mapInBackgroundClosure(realmObject)

            completion(mappedObject)
        }
    }
    
    func readAndMapObjectPublisher<T: Object, U>(primaryKey: String, mapInBackgroundClosure: @escaping ((_ object: T?) -> U?)) -> AnyPublisher<U?, Never> {
        
        return Future() { promise in
            
            self.readAndMapObjectInBackground(primaryKey: primaryKey, mapInBackgroundClosure: mapInBackgroundClosure) { (mappedObject: U?) in
                
                promise(.success(mappedObject))
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

// MARK: - Read Objects With Mapping

extension RealmDatabase {
    
    func readAndMapObjectsInBackground<T: Object, U>(mapInBackgroundClosure: @escaping ((_ results: Results<T>) -> [U]), completion: @escaping ((_ mappedObjects: [U]) -> Void)) {
        
        background { realm in
            
            let results: Results<T> = self.readObjects(realm: realm)
            
            let mappedObjects: [U] = mapInBackgroundClosure(results)

            completion(mappedObjects)
        }
    }
    
    func readAndMapObjectsPublisher<T: Object, U>(mapInBackgroundClosure: @escaping ((_ results: Results<T>) -> [U])) -> AnyPublisher<[U], Never> {
        
        return Future() { promise in
            
            self.readAndMapObjectsInBackground(mapInBackgroundClosure: mapInBackgroundClosure) { (mappedObjects: [U]) in
                
                promise(.success(mappedObjects))
            }
        }
        .eraseToAnyPublisher()
    }
}
