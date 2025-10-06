//
//  ProductionSwiftDatabaseConfig.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
struct ProductionSwiftDatabaseConfig: SwiftDatabaseConfigInterface {
    
    var modelConfiguration: ModelConfiguration {
        
        return ModelConfiguration(
            "godtools_swiftdata_production",
            schema: nil,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none
        )
    }
}
