//
//  SwiftDatabaseConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
class SwiftDatabaseConfiguration: SwiftDatabaseConfigInterface {
    
    let modelConfiguration: ModelConfiguration
    
    init(modelConfiguration: ModelConfiguration) {
        
        self.modelConfiguration = modelConfiguration
    }
}
