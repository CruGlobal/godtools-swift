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
