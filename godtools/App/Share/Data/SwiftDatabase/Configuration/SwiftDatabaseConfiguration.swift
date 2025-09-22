//
//  SwiftDatabaseConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 9/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
class SwiftDatabaseConfiguration: SwiftDatabaseConfigurationInterface {
    
    let modelConfiguration: ModelConfiguration
    
    init(modelConfiguration: ModelConfiguration) {
        
        self.modelConfiguration = modelConfiguration
    }
}
