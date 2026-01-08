//
//  UITestsRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift
import Realm

class UITestsRealmDatabase {
    
    private let diskFileName: String = "godtools_uitests_realm"
    
    let legacyRealmDatabase: LegacyRealmDatabase
    let realmDatabase: RealmDatabase
    
    init() throws {
        
        let realmConfig: Realm.Configuration = Self.getRealmConfig(diskFileName: diskFileName)
        
        legacyRealmDatabase = LegacyRealmDatabase(config: realmConfig)
        
        realmDatabase = RealmDatabase(databaseConfig: RealmDatabaseConfig(config: realmConfig))
                
        // TODO: Will comment out for now until url requests are disabled in UITestsAppConfig.swift. ~Levi
        //try addObjectsIfNeeded(realmDatabase: realmDatabase)
    }
    
    private static func getRealmConfig(diskFileName: String) -> Realm.Configuration {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        let fileUrl = URL(fileURLWithPath: RLMRealmPathForFile(diskFileName), isDirectory: false)
        
        let config = Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: 1,
            migrationBlock: migrationBlock
        )
        
        return config
    }
    
    private func addObjectsIfNeeded(realmDatabase: RealmDatabase) throws {
                
        let realm: Realm = try realmDatabase.openRealm()
        
        let resources: [RealmResource] = realmDatabase.read.objects(realm: realm, query: nil)
        
        guard resources.count == 0 else {
            return
        }
        
        let uiTestsRealmObjects = UITestsRealmObjects()
        
        let objects: [IdentifiableRealmObject] = uiTestsRealmObjects.getResources() + uiTestsRealmObjects.getLanguages()
        
        try realmDatabase.write.objects(realm: realm, writeClosure: { (realm: Realm) in
            
            return WriteRealmObjects(deleteObjects: [], addObjects: objects)
            
        }, updatePolicy: .modified)
    }
}
