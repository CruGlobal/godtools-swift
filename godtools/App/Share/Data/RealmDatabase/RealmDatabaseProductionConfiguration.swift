//
//  RealmDatabaseProductionConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 11/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class RealmDatabaseProductionConfiguration: RealmDatabaseConfiguration {
    
    private static let diskFileName: String = "godtools_realm"
    private static let schemaVersion: UInt64 = 14
    
    init() {
        
        super.init(
            cacheType: .disk(fileName: RealmDatabaseProductionConfiguration.diskFileName),
            schemaVersion: RealmDatabaseProductionConfiguration.schemaVersion
        )
    }
}
