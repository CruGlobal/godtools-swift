//
//  TestsInMemorySwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
class TestsInMemorySwiftDatabase: godtools.SwiftDatabase {
    
    init(addObjectsToDatabase: [any IdentifiableSwiftDataObject] = Array()) {
        
        super.init(
            config: InMemorySwiftDatabaseConfig(),
            schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self),
            migrationPlan: nil
        )
        
        do {
            try super.saveObjects(
                context: super.openContext(),
                objectsToAdd: addObjectsToDatabase,
                objectsToRemove: []
            )
        }
        catch let error {
            print("\n WARNING: TestsInMemorySwiftDatabase failed to add objects to database with error: \(error)")
            assertionFailure(error.localizedDescription)
        }
    }
}
