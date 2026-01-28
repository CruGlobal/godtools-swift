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
    
    convenience init(realmFileName: String? = nil, addRealmObjects: [IdentifiableRealmObject] = Array()) throws {
        
        let legacyRealmDatabase: LegacyRealmDatabase
        let realmDatabase: RealmDatabase
        
        if let realmFileName = realmFileName, !realmFileName.isEmpty {
            
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
            
            legacyRealmDatabase = LegacyRealmDatabase(config: config)
            
            realmDatabase = RealmDatabase(databaseConfig: RealmDatabaseConfig(config: config))
            
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
        }
        else {
            
            let realmDatabaseId: String = UUID().uuidString
            let realmSchemaVersion: UInt64 = 1
            
            legacyRealmDatabase = try MockLegacyRealmDatabase().createInMemoryDatabase(
                addObjects: addRealmObjects,
                identifier: realmDatabaseId,
                schemaVersion: realmSchemaVersion
            )
            
            realmDatabase = try MockRealmDatabase().createInMemoryDatabase(
                addObjects: addRealmObjects,
                identifier: realmDatabaseId,
                schemaVersion: realmSchemaVersion
            )
        }
        
        let appConfig = TestsAppConfig(
            legacyRealmDatabase: legacyRealmDatabase,
            realmDatabase: realmDatabase
        )
        
        self.init(testsAppConfig: appConfig)
    }
}
