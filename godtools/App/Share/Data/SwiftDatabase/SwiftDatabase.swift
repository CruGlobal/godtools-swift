//
//  SwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
class SwiftDatabase {
    
    private let container: ModelContainer
    
    let configName: String
    
    init(config: SwiftDatabaseConfigInterface, schema: Schema, migrationPlan: (any SchemaMigrationPlan.Type)?) {
                
        do {
            
            container = try Self.createContainer(
                config: config,
                schema: schema,
                migrationPlan: migrationPlan
            )
        }
        catch let error {
            
            assertionFailure("\n SwiftData init container error: \(error.localizedDescription)")
            
            container = try! Self.createContainer(
                config: InMemorySwiftDatabaseConfig(),
                schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self),
                migrationPlan: nil
            )
        }
        
        configName = config.modelConfiguration.name
    }
    
    private static func createContainer(config: SwiftDatabaseConfigInterface, schema: Schema, migrationPlan: (any SchemaMigrationPlan.Type)?) throws -> ModelContainer {
        
        return try ModelContainer(
            for: schema,
            migrationPlan: migrationPlan,
            configurations: config.modelConfiguration
        )
    }
    
    func openContext() -> ModelContext {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return context
    }
    
    func deleteAllData() {
        
        if #available(iOS 18, *) {
            do {
                try container.erase()
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
        else {
            container.deleteAllData()
        }
    }
}
