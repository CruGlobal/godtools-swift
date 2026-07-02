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
import RealmSwift
import Realm

class TestsDiContainer: AppDiContainer {
    
    init(testsAppConfig: TestsAppConfig) {
   
        super.init(appConfig: testsAppConfig)
    }
    
    convenience init(addRealmObjects: [IdentifiableRealmObject] = Array()) throws {
        
        let databaseConfig = try RealmDatabaseConfig.createInMemoryConfig()
        
        let database = RealmDatabase(databaseConfig: databaseConfig)
        
        if addRealmObjects.count > 0 {
            
            let realm: Realm = try database.openRealm()
            
            try realm.write {
                realm.add(addRealmObjects, update: .modified)
            }
        }
        
        let appConfig = TestsAppConfig(
            realmDatabase: database
        )
        
        self.init(testsAppConfig: appConfig)
    }
}
