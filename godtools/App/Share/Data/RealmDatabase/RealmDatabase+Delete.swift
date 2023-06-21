//
//  RealmDatabase+Delete.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

extension RealmDatabase {
 
    func deleteObjects(realm: Realm, objects: [Object]) -> Error? {
        
        do {
            
            try realm.write {
                
                realm.delete(objects)
            }
            
            return nil
        }
        catch let error {
            
            return error
        }
    }
    
    func deleteObjectsInBackground(objects: [Object], completion: @escaping ((_ result: Result<Void, Error>) -> Void)) {
        
        self.background { realm in
            
            let error: Error? = self.deleteObjects(
                realm: realm,
                objects: objects
            )
            
            if let error = error {
                completion(.failure(error))
            }
            else {
                completion(.success(()))
            }
        }
    }
    
    func deleteObjectsPublisher(objects: [Object]) -> AnyPublisher<Void, Error> {
        
        return Future() { promise in
            
            self.deleteObjectsInBackground(objects: objects) { result in
                
                switch result {
                    
                case .success(let void):
                    promise(.success(void))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteAllObjects(realm: Realm) -> Error? {
                
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
    
    func deleteAllObjects() -> Error? {
        
        let realm: Realm = openRealm()
        
        return deleteAllObjects(realm: realm)
    }
}
