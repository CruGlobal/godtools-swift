//
//  MockRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 1/8/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RealmSwift
import RepositorySync

final class MockRealmDatabase {
    
    init() {
        
    }
    
    func createInMemoryDatabase(addObjects: [IdentifiableRealmObject], identifier: String? = nil, schemaVersion: UInt64? = nil) throws -> RealmDatabase {
        
        let database = RealmDatabase(
            databaseConfig: RealmDatabaseConfig.createInMemoryConfig(
                inMemoryIdentifier: identifier ?? UUID().uuidString,
                schemaVersion: schemaVersion ?? 1
            )
        )
        
        let realm: Realm = try database.openRealm()
        
        try database.write.realm(
            realm: realm,
            writeClosure: { (realm: Realm) in
                return WriteRealmObjects(
                    deleteObjects: nil,
                    addObjects: addObjects
                )
            },
            updatePolicy: .modified
        )

        return database
    }
}
