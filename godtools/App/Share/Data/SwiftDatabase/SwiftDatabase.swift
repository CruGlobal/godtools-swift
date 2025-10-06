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
    
    init(configuration: SwiftDatabaseConfigurationInterface, migration: SwiftDatabaseMigrationPlanInterface) {
                
        do {
            
            container = try Self.createContainer(
                configuration: configuration,
                migration: migration
            )
        }
        catch let error {
            
            assertionFailure("\n SwiftData init container error: \(error.localizedDescription)")
            
            container = try! Self.createContainer(
                configuration: SwiftDatabaseInMemoryConfiguration(),
                migration: migration
            )
        }
        
        configName = configuration.modelConfiguration.name
    }
    
    private static func createContainer(configuration: SwiftDatabaseConfigurationInterface, migration: SwiftDatabaseMigrationPlanInterface) throws -> ModelContainer {
        
        return try ModelContainer(
            for: Schema(versionedSchema: GodToolsSchemaV2.self),
            migrationPlan: migration.migrationPlan,
            configurations: configuration.modelConfiguration
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
