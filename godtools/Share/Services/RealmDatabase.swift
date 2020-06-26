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
    
    private let backgroundConfig: Realm.Configuration = RealmDatabase.createBackgroundConfig
    private let backgroundQueue: DispatchQueue = DispatchQueue(label: "realm.background_queue", attributes: .concurrent)
    
    required init() {
        
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
        
        let configuration = backgroundConfig
        
        backgroundQueue.async {
            autoreleasepool {
                
                let realm: Realm
               
                do {
                    realm = try Realm(configuration: configuration)
                }
                catch let error {
                    assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
                    realm = try! Realm(configuration: configuration)
                }
                
                async(realm)
            }
        }
    }
    
    private static var createBackgroundConfig: Realm.Configuration {
        
        var config = Realm.Configuration()
        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("shared_background_realm")
        config.schemaVersion = 1
        
        config.migrationBlock = { migration, oldSchemaVersion in
            
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        return config
    }
}
