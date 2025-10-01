//
//  SharedSwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

// TODO: GT-2753 Can be removed and moved to AppDataLayerDependencies once RealmSwift is removed and supporting iOS 17 and up. ~Levi
@available(iOS 17, *)
class SharedSwiftDatabase {
    
    private static let swiftDatabaseEnabled: Bool = true
    
    static let shared: SharedSwiftDatabase = SharedSwiftDatabase()
    
    private let sharedSwiftDatabase: SwiftDatabase = SwiftDatabase(
        configuration: SwiftDatabaseProductionConfiguration(),
        modelTypes: GodToolsSwiftDataModelTypes(),
        migration: GodToolsMigrationPlan()
    )
    
    var swiftDatabase: SwiftDatabase? {
        Self.swiftDatabaseEnabled ? sharedSwiftDatabase : nil
    }
    
    private init() {
        
    }
}
