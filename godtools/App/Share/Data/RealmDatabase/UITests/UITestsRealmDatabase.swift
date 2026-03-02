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
    
    static func getLegacyRealmDatabase() -> LegacyRealmDatabase {
        
        let legacyRealmDatabase = LegacyRealmDatabase(
            realmDatabase: Self.getRealmDatabase()
        )
                
        return legacyRealmDatabase
    }
    
    static func getRealmDatabase() -> RealmDatabase {
        
        let realmDatabase = RealmDatabase(databaseConfig: getRealmDatabaseConfig())
        
        return realmDatabase
    }
}
