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

// MARK: - Delete Objects By Primary Keys

extension RealmDatabase {
    
    func deleteObjectsInBackground<Element: RealmFetchable>(type: Element.Type, primaryKeyPath: String, primaryKeys: [String], completion: @escaping ((_ result: Result<Void, Error>) -> Void)) {
        
        self.background { (realm: Realm) in
            
            let results: Results<Element> = realm.objects(type)
                .filter("\(primaryKeyPath) IN %@", primaryKeys)
            
            let objects: [ObjectBase] = Array(results) as? [ObjectBase] ?? Array()
            
            let deleteObjectsError: Error? = self.deleteObjects(realm: realm, objects: objects)
            
            if let deleteObjectsError = deleteObjectsError {
                
                completion(.failure(deleteObjectsError))
            }
            else {
                
                completion(.success(Void()))
            }
        }
    }
    
    func deleteObjectsInBackgroundPublisher<Element: RealmFetchable>(type: Element.Type, primaryKeyPath: String, primaryKeys: [String]) -> AnyPublisher<Void, Error> {

        return Future() { promise in
            
            self.deleteObjectsInBackground(type: type, primaryKeyPath: primaryKeyPath, primaryKeys: primaryKeys) { (result: Result<Void, Error>) in
                
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

// MARK: - Delete Objects

extension RealmDatabase {
 
    func deleteObjects(realm: Realm, objects: [ObjectBase]) -> Error? {
        
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
}

// MARK: - Delete All Objects

extension RealmDatabase {
    
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
