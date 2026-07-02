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
    
    static func getRealmDatabaseConfig() throws -> RealmDatabaseConfig {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        return try RealmDatabaseConfig(
            fileName: Self.diskFileName,
            schemaVersion: RealmProductionConfig.schemaVersion,
            migrationBlock: migrationBlock
        )
    }
}
