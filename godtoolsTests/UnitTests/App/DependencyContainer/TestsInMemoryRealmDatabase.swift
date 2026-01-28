//
//  TestsInMemoryRealmDatabase.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RealmSwift

// TODO: Remove this class. ~Levi
@available(*, deprecated)
class TestsInMemoryRealmDatabase: LegacyRealmDatabase {
    
    // NOTE: In our tests realm database we default to using a shared realm instance to avoid any issues of data loss when using an in memory realm database. ~Levi
    // See realm's documentation on in memory realm instances (https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/realm-files/configure-and-open-a-realm/#open-an-in-memory-realm)
    
    init(schemaVersion: UInt64 = 1, addObjectsToDatabase: [Object] = Array()) {
                
        let config = Realm.Configuration(
            inMemoryIdentifier: UUID().uuidString,
            schemaVersion: schemaVersion
        )
        
        super.init(config: config)
        
        if !addObjectsToDatabase.isEmpty {
            
            let realm: Realm = openRealm()
                        
            do {
                try realm.write {
                    realm.add(addObjectsToDatabase, update: .all)
                }
            }
            catch _ {
                
            }
        }
    }
}
