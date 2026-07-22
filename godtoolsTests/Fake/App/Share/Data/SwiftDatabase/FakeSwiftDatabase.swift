//
//  FakeSwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RepositorySync
import SwiftData

@available(iOS 17.4, *)
final class FakeSwiftDatabase {

    static func createSwiftDatabase(addObjects: [any PersistentModel] = Array()) throws -> SwiftDatabase {

        let container = try SwiftDataContainer.createInMemoryContainer(
            schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
        )

        let database = SwiftDatabase(container: container)

        if addObjects.count > 0 {

            let context: ModelContext = database.openContext()

            context.insertObjects(objects: addObjects)

            try context.saveIfHasChanges()
        }

        return database
    }
}
