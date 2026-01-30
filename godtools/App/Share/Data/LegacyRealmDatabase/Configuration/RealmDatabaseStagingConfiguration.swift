//
//  RealmDatabaseStagingConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDatabaseStagingConfiguration: RealmDatabaseConfiguration {
        
    init() {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        super.init(
            cacheType: .disk(fileName: RealmStagingConfig.diskFileName, migrationBlock: migrationBlock),
            schemaVersion: RealmProductionConfig.schemaVersion
        )
    }
}
