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
    
    init(configuration: SwiftDatabaseConfigurationInterface, modelTypes: SwiftDatabaseModelTypesInterface) {
                
        do {
            
            container = try Self.createContainer(
                configuration: configuration,
                modelTypes: modelTypes
            )
        }
        catch let error {
            
            assertionFailure("\n SwiftData init container error: \(error.localizedDescription)")
            
            container = try! Self.createContainer(
                configuration: SwiftDatabaseInMemoryConfiguration(),
                modelTypes: modelTypes
            )
        }
        
        configName = configuration.modelConfiguration.name
    }
    
    private static func createContainer(configuration: SwiftDatabaseConfigurationInterface, modelTypes: SwiftDatabaseModelTypesInterface) throws -> ModelContainer {
        
        return try ModelContainer(
            for: Schema(modelTypes.getModelTypes()),
            migrationPlan: nil,
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
