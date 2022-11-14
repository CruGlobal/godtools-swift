//
//  RealmDatabaseConfiguration+RealmConfig.swift
//  godtools
//
//  Created by Levi Eggert on 11/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmDatabaseConfiguration {
    
    func getRealmConfig() -> Realm.Configuration {
        
        var realmConfig: Realm.Configuration
        
        switch cacheType {
            
        case .disk(let fileName):
            
            realmConfig = Realm.Configuration()
            realmConfig.fileURL = realmConfig.fileURL?.deletingLastPathComponent().appendingPathComponent(fileName)
            realmConfig.schemaVersion = schemaVersion
            
            realmConfig.migrationBlock = { migration, oldSchemaVersion in
                
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        
        case .inMemory(let identifier):
            
            realmConfig = Realm.Configuration(inMemoryIdentifier: identifier)
            realmConfig.schemaVersion = schemaVersion
        }
        
        return realmConfig
    }
}
