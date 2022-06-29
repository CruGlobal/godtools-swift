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
    
    private static let config: Realm.Configuration = RealmDatabase.createConfig
    private static let schemaVersion: UInt64 = 8
    
    private let backgroundQueue: DispatchQueue = DispatchQueue(label: "realm.background_queue", attributes: .concurrent)
    
    let mainThreadRealm: Realm
    
    required init() {
        
        do {
            self.mainThreadRealm = try Realm(configuration: RealmDatabase.config)
        }
        catch let error {
            assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
            self.mainThreadRealm = try! Realm(configuration: RealmDatabase.config)
        }
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
                
        backgroundQueue.async {
            autoreleasepool {
                
                let realm: Realm
               
                do {
                    realm = try Realm(configuration: RealmDatabase.config)
                }
                catch let error {
                    assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
                    realm = try! Realm(configuration: RealmDatabase.config)
                }
                
                async(realm)
            }
        }
    }
    
    func getObjects<T: Object>(realm: Realm, primaryKeys: [String]) -> [T] {
        
        var objects: [T] = Array()
        
        for key in primaryKeys {
            if let object = realm.object(ofType: T.self, forPrimaryKey: key) {
                objects.append(object)
            }
        }
        
        return objects
    }
    
    private static var createConfig: Realm.Configuration {
        
        var config = Realm.Configuration()
        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("godtools_realm")
        config.schemaVersion = RealmDatabase.schemaVersion
        
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
