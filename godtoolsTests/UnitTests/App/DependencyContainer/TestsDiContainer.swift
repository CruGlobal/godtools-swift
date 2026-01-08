//
//  TestsDiContainer.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RepositorySync

class TestsDiContainer: AppDiContainer {
    
    init(testsAppConfig: TestsAppConfig) {
   
        super.init(appConfig: testsAppConfig)
    }
    
    convenience init(addRealmObjects: [IdentifiableRealmObject]) throws {
        
        let realmDatabaseId: String = UUID().uuidString
        let realmSchemaVersion: UInt64 = 1
        
        let legacyRealmDatabase: LegacyRealmDatabase = try MockLegacyRealmDatabase().createInMemoryDatabase(
            addObjects: addRealmObjects,
            identifier: realmDatabaseId,
            schemaVersion: realmSchemaVersion
        )
        
        let realmDatabase: RealmDatabase = try MockRealmDatabase().createInMemoryDatabase(
            addObjects: addRealmObjects,
            identifier: realmDatabaseId,
            schemaVersion: realmSchemaVersion
        )
        
        let appConfig = TestsAppConfig(
            legacyRealmDatabase: legacyRealmDatabase,
            realmDatabase: realmDatabase
        )
        
        self.init(testsAppConfig: appConfig)
    }
}
