//
//  SwiftDataProductionContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
final class SwiftDataProductionContainer {
    
    static let configName: String = "godtools_swiftdata_production"
    
    init() {
        
    }
    
    static func createInMemoryContainer(name: String = UUID().uuidString) throws -> SwiftDataContainer {
        
        return try SwiftDataContainer.createInMemoryContainer(
            name: name,
            schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
        )
    }
    
    static func createContainer() throws -> SwiftDataContainer {
        
        let modelConfig = ModelConfiguration(
            Self.configName,
            schema: nil,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none
        )
        
        return try SwiftDataContainer(
            modelConfiguration: modelConfig,
            schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self),
            migrationPlan: nil
        )
    }
}
