//
//  TempSharedSwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

// TODO: GT-2753 Can be removed and moved to AppDataLayerDependencies once RealmSwift is removed and supporting iOS 17 and up. ~Levi
@available(iOS 17.4, *)
class TempSharedSwiftDatabase {
    
    private static let swiftDatabaseEnabled: Bool = false
    
    static let shared: TempSharedSwiftDatabase = TempSharedSwiftDatabase()
    
    private let sharedSwiftDatabase: SwiftDatabase = SwiftDatabase(
        config: ProductionSwiftDatabaseConfig(),
        schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self),
        migrationPlan: nil
    )
    
    var swiftDatabase: SwiftDatabase? {
        Self.swiftDatabaseEnabled ? sharedSwiftDatabase : nil
    }
    
    private init() {
        
    }
}
