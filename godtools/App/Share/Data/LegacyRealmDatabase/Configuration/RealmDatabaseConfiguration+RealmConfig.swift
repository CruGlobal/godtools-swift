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
            
        case .disk(let fileName, let migrationBlock):
            
            realmConfig = Realm.Configuration()
            realmConfig.fileURL = realmConfig.fileURL?.deletingLastPathComponent().appendingPathComponent(fileName)
            realmConfig.schemaVersion = schemaVersion
            realmConfig.migrationBlock = migrationBlock
        
        case .inMemory(let identifier):
            
            realmConfig = Realm.Configuration(inMemoryIdentifier: identifier)
            realmConfig.schemaVersion = schemaVersion
        }
        
        return realmConfig
    }
}
