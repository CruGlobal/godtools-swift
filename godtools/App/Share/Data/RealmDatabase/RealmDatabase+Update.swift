//
//  RealmDatabase+Update.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

extension RealmDatabase {
    
    func updateObjects(realm: Realm, shouldAddObjectsToRealm: Bool = true, updatePolicy: Realm.UpdatePolicy = .all, writeClosure: @escaping ((_ realm: Realm) -> [Object])) -> Error? {
        
        do {
            
            try realm.write {
                
                let objects: [Object] = writeClosure(realm)
                
                if shouldAddObjectsToRealm {
                    realm.add(objects, update: updatePolicy)
                }
            }
            
            return nil
        }
        catch let error {
            
            return error
        }
    }
    
    func updateObjectsInBackground(shouldAddObjectsToRealm: Bool = true, updatePolicy: Realm.UpdatePolicy = .all, writeClosure: @escaping ((_ realm: Realm) -> [Object]), completion: @escaping ((_ result: Result<Void, Error>) -> Void)) {
        
        self.background { realm in
            
            let error: Error? = self.updateObjects(
                realm: realm,
                shouldAddObjectsToRealm: shouldAddObjectsToRealm,
                updatePolicy: updatePolicy,
                writeClosure: writeClosure
            )
            
            if let error = error {
                completion(.failure(error))
            }
            else {
                completion(.success(()))
            }
        }
    }
    
    func updateObjectsPublisher(shouldAddObjectsToRealm: Bool = true, updatePolicy: Realm.UpdatePolicy = .all, writeClosure: @escaping ((_ realm: Realm) -> [Object])) -> AnyPublisher<Void, Error> {
        
        return Future() { promise in
            
            self.updateObjectsInBackground(shouldAddObjectsToRealm: shouldAddObjectsToRealm, updatePolicy: updatePolicy, writeClosure: writeClosure) { result in
                
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
}
