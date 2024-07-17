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
    
    init(schemaVersion: UInt64 = 1, realmInstanceCreationType: RealmInstanceCreationType = .alwaysCreatesANewRealmInstance) {
        
        let uniqueId: String = "godtoolsTests" + UUID().uuidString
        
        super.init(
            databaseConfiguration: RealmDatabaseConfiguration(cacheType: .inMemory(identifier: uniqueId), schemaVersion: schemaVersion),
            realmInstanceCreationType: realmInstanceCreationType
        )
    }
}
