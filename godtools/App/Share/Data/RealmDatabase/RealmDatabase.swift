//
//  RealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmDatabase {
    
    private let databaseConfiguration: RealmDatabaseConfiguration
    private let config: Realm.Configuration
    private let backgroundQueue: DispatchQueue = DispatchQueue(label: "realm.background_queue")
    
    init(databaseConfiguration: RealmDatabaseConfiguration) {
        
        self.databaseConfiguration = databaseConfiguration
        config = databaseConfiguration.getRealmConfig()
    }

    func openRealm() -> Realm {
        return try! Realm(configuration: config)
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
                
        backgroundQueue.async {
            autoreleasepool {
                
                let realm: Realm
               
                do {
                    realm = try Realm(configuration: self.config)
                }
                catch let error {
                    assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
                    realm = try! Realm(configuration: self.config)
                }
                
                async(realm)
            }
        }
    }
    
    func backgroundRealmPublisher() -> AnyPublisher<Realm, Never> {
        
        return Future() { promise in
            
            self.background { realm in
                
                promise(.success(realm))
            }
        }
        .eraseToAnyPublisher()
    }
}
