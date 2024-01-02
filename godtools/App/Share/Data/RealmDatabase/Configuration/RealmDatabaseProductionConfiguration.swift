//
//  RealmDatabaseProductionConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 11/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDatabaseProductionConfiguration: RealmDatabaseConfiguration {
    
    private static let diskFileName: String = "godtools_realm"
    private static let schemaVersion: UInt64 = 27
    
    init() {
        
        let migrationBlock = { (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        super.init(
            cacheType: .disk(fileName: RealmDatabaseProductionConfiguration.diskFileName, migrationBlock: migrationBlock),
            schemaVersion: RealmDatabaseProductionConfiguration.schemaVersion
        )
    }
}
