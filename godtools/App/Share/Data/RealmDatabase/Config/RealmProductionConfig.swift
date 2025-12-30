//
//  RealmProductionConfig.swift
//  godtools
//
//  Created by Levi Eggert on 12/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class RealmProductionConfig {
    
    static let diskFileName: String = "godtools_realm"
    static let schemaVersion: UInt64 = 37
    
    func createConfig() -> RealmDatabaseConfig {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        return RealmDatabaseConfig(
            fileName: Self.diskFileName,
            schemaVersion: Self.schemaVersion,
            migrationBlock: migrationBlock
        )
    }
}
