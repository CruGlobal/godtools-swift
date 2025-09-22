//
//  SwiftDatabaseProductionConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
class SwiftDatabaseProductionConfiguration: SwiftDatabaseConfigurationInterface {
    
    let modelConfiguration: ModelConfiguration
    
    init() {
        
        modelConfiguration = ModelConfiguration(
            "godtools_swiftdata_production",
            schema: nil,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none
        )
    }
}
