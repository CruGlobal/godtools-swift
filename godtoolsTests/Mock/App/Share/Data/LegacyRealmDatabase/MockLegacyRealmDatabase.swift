//
//  MockLegacyRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 1/8/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RealmSwift

final class MockLegacyRealmDatabase {
    
    init() {
        
    }
    
    func createInMemoryDatabase(addObjects: [Object], identifier: String? = nil, schemaVersion: UInt64? = nil) throws -> LegacyRealmDatabase {
        
        let identifier: String = identifier ?? UUID().uuidString
        let schemaVersion: UInt64 = schemaVersion ?? 1
        
        let config = Realm.Configuration(
            inMemoryIdentifier: identifier,
            schemaVersion: schemaVersion
        )
        
        let database = LegacyRealmDatabase(
            config: config
        )
        
        if !addObjects.isEmpty {
            
            let realm: Realm = database.openRealm()
            
            try realm.write {
                realm.add(addObjects, update: .all)
            }
        }
        
        return database
    }
}
