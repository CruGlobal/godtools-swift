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
    
    init(configuration: SwiftDatabaseConfigurationInterface) {
                
        do {
            
            container = try Self.createContainer(
                configuration: configuration
            )
        }
        catch let error {
            
            assertionFailure("\n SwiftData init container error: \(error.localizedDescription)")
            
            container = try! Self.createContainer(
                configuration: SwiftDatabaseInMemoryConfiguration()
            )
        }
    }
    
    private static func createContainer(configuration: SwiftDatabaseConfigurationInterface) throws -> ModelContainer {
        return try ModelContainer(
            for: Self.persistentModelTypes,
            configurations: configuration.modelConfiguration
        )
    }
    
    private static var persistentModelTypes: any PersistentModel.Type {
        return SwiftLanguage.self
    }
}
