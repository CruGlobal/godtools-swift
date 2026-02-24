//
//  UITestsRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class UITestsRealmDatabase {
    
    private static let diskFileName: String = "godtools_uitests_realm"
    
    init() {
        
    }
    
    private static func getRealmDatabaseConfig() -> RealmDatabaseConfig {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        return RealmDatabaseConfig(
            fileName: Self.diskFileName,
            schemaVersion: RealmProductionConfig.schemaVersion,
            migrationBlock: migrationBlock
        )
    }
    
    private static func addInitialRealmObjects(realm: Realm) {
        
        let objects: [Object] = UITestsRealmObjects.getAllObjects()
        
        do {
            try realm.write {
                realm.add(objects, update: .all)
            }
        }
        catch let error {
            assertionFailure("\n UITestsRealmDatabase: Failed to add objects with error.\n  error: \(error)")
        }
    }
    
    static func getLegacyRealmDatabase() -> LegacyRealmDatabase {
        
        let legacyRealmDatabase = LegacyRealmDatabase(
            config: getRealmDatabaseConfig().config
        )
                
        let realm: Realm = legacyRealmDatabase.openRealm()
        
        Self.addInitialRealmObjects(realm: realm)
        
        return legacyRealmDatabase
    }
    
    static func getRealmDatabase() -> RealmDatabase {
        
        let realmDatabase = RealmDatabase(databaseConfig: getRealmDatabaseConfig())
        
        do {
            let realm: Realm = try realmDatabase.openRealm()
            Self.addInitialRealmObjects(realm: realm)
        }
        catch let error {
            assertionFailure("\n UITestsRealmDatabase: Failed to get realm with error.\n  error: \(error)")
        }
        
        return realmDatabase
    }
}
