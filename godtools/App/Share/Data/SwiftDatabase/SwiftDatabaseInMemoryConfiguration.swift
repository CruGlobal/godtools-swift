//
//  SwiftDatabaseInMemoryConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
class SwiftDatabaseInMemoryConfiguration: SwiftDatabaseConfigurationInterface {
    
    let modelConfiguration: ModelConfiguration
    
    init() {
        
        modelConfiguration = ModelConfiguration(
            "godtools_swiftdata_in_memory",
            schema: nil,
            isStoredInMemoryOnly: true,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
    }
}
