//
//  RealmDatabase+Write.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

extension RealmDatabase {
    
    func writeObjects<T: Object>(realm: Realm, shouldAddObjectsToRealm: Bool = true, updatePolicy: Realm.UpdatePolicy = .all, writeClosure: @escaping ((_ realm: Realm) -> [T])) -> Result<[T], Error> {
        
        do {
            
            var objects: [T] = Array()
            
            try realm.write {
                
                objects = writeClosure(realm)
                
                if shouldAddObjectsToRealm {
                    realm.add(objects, update: updatePolicy)
                }
            }
            
            return .success(objects)
        }
        catch let error {
            
            return .failure(error)
        }
    }
    
    func writeObjectsInBackground<T: Object>(shouldAddObjectsToRealm: Bool = true, updatePolicy: Realm.UpdatePolicy = .all, writeClosure: @escaping ((_ realm: Realm) -> [T]), completion: @escaping ((_ result: Result<[T], Error>) -> Void)) {
        
        self.background { realm in
            
            let result: Result<[T], Error> = self.writeObjects(
                realm: realm,
                shouldAddObjectsToRealm: shouldAddObjectsToRealm,
                updatePolicy: updatePolicy,
                writeClosure: writeClosure
            )
            
            completion(result)
        }
    }
    
    func writeObjectsPublisher<T: Object>(shouldAddObjectsToRealm: Bool = true, updatePolicy: Realm.UpdatePolicy = .all, writeClosure: @escaping ((_ realm: Realm) -> [T])) -> AnyPublisher<[T], Error> {
        
        return Future() { promise in
            
            self.writeObjectsInBackground(shouldAddObjectsToRealm: shouldAddObjectsToRealm, updatePolicy: updatePolicy, writeClosure: writeClosure) { result in
                
                switch result {
                    
                case .success(let objects):
                    promise(.success(objects))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
