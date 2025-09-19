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
            container = try ModelContainer(
                for: Self.persistentTypes,
                configurations: configuration.modelConfiguration
            )
        }
        catch let error {
            assertionFailure("\n SwiftData init container error: \(error.localizedDescription)")
            container = try! ModelContainer(for: Self.persistentTypes, configurations: SwiftDatabaseInMemoryConfiguration().modelConfiguration)
        }
    }
    
    private static var persistentTypes: any PersistentModel.Type {
        return SwiftLanguage.self
    }
}
