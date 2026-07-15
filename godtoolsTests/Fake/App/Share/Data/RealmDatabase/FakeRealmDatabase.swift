//
//  FakeRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

final class FakeRealmDatabase {
    
    static func createRealmDatabase(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> RealmDatabase {
        
        let databaseConfig = try RealmDatabaseConfig.createInMemoryConfig()
        
        let database = RealmDatabase(databaseConfig: databaseConfig)
        
        if addRealmObjects.count > 0 {
            
            let realm: Realm = try database.openRealm()
            
            try realm.write {
                realm.add(addRealmObjects, update: .modified)
            }
        }
        
        return database
    }
}
