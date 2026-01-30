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
    
    convenience init(realmFileName: String, addRealmObjects: [IdentifiableRealmObject] = Array()) throws {
        
        let fileUrl = URL(fileURLWithPath: RLMRealmPathForFile(realmFileName), isDirectory: false)
        
        if FileManager.default.getFilePathExists(url: fileUrl) {
            try FileManager.default.removeUrl(url: fileUrl)
        }
        
        let config = Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: 1,
            migrationBlock: { (_, _) in
                
            }
        )
        
        let legacyRealmDatabase = LegacyRealmDatabase(config: config)
        
        let realmDatabase = RealmDatabase(databaseConfig: RealmDatabaseConfig(config: config))
        
        let realm: Realm = try realmDatabase.openRealm()
        
        try realmDatabase.write.realm(
            realm: realm,
            writeClosure: { (realm: Realm) in
                return WriteRealmObjects(
                    deleteObjects: nil,
                    addObjects: addRealmObjects
                )
            },
            updatePolicy: .modified
        )
        
        let appConfig = TestsAppConfig(
            legacyRealmDatabase: legacyRealmDatabase,
            realmDatabase: realmDatabase
        )
        
        self.init(testsAppConfig: appConfig)
    }
}
