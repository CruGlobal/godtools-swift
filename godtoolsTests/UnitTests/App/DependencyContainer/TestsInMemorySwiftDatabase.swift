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
class TestsInMemorySwiftDatabase {
    
    init() {

    }
    
    func createDatabase(addObjectsToDatabase: [any IdentifiableSwiftDataObject] = Array()) throws -> SwiftDatabase {
        
        let database = SwiftDatabase(
            container: try SwiftDataContainer.createInMemoryContainer(
                schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
            )
        )
        
        let context: ModelContext = database.openContext()
        
        try database
            .write
            .objects(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: nil, insertObjects: addObjectsToDatabase)
            )
        
        return database
    }
}
