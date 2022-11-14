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
    
    private let config: Realm.Configuration
    private let backgroundQueue: DispatchQueue = DispatchQueue(label: "realm.background_queue")
        
    @available(*, deprecated) // TODO: Would like to move away from using the mainThreadRealm and instead use the func openRealm() since realm instances cant be shared across threads. ~Levi
    let mainThreadRealm: Realm
    
    init(databaseConfiguration: RealmDatabaseConfiguration) {
        
        config = databaseConfiguration.getRealmConfig()
        
        do {
            self.mainThreadRealm = try Realm(configuration: config)
        }
        catch let error {
            assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
            self.mainThreadRealm = try! Realm(configuration: config)
        }
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
}
