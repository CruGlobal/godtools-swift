//
//  TestsInMemoryRealmDatabase.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsInMemoryRealmDatabase: RealmDatabase {
    
    init(identifier: String = "godtoolsTests", schemaVersion: UInt64 = 1) {
        
        super.init(
            databaseConfiguration: RealmDatabaseConfiguration(cacheType: .inMemory(identifier: identifier), schemaVersion: schemaVersion)
        )
    }
}
