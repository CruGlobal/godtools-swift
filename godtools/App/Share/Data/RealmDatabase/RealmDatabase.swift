//
//  RealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDatabase {
    
    private let databaseConfiguration: RealmDatabaseConfiguration
    private let config: Realm.Configuration
    private let backgroundQueue: DispatchQueue = DispatchQueue(label: "realm.background_queue")
    
    private lazy var isInMemory: Bool = {
        return config.inMemoryIdentifier != nil
    }()
    private lazy var inMemRealm: Realm = {
        return try! Realm(configuration: config)
    }()
    
    init(databaseConfiguration: RealmDatabaseConfiguration) {
        
        self.databaseConfiguration = databaseConfiguration
        config = databaseConfiguration.getRealmConfig()
    }

    func openRealm() -> Realm {
        if isInMemory {
            
            return inMemRealm
        }
        
        return try! Realm(configuration: config)
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
        if isInMemory {
            async(inMemRealm)
            return
        }
        
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
}
