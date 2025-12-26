//
//  RealmDatabaseConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 11/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class RealmDatabaseConfiguration {
    
    let cacheType: RealmDatabaseCacheType
    let schemaVersion: UInt64
    
    init(cacheType: RealmDatabaseCacheType, schemaVersion: UInt64) {
        
        self.cacheType = cacheType
        self.schemaVersion = schemaVersion
    }
}
