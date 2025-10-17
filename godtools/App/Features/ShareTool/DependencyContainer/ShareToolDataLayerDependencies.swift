//
//  ShareToolDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ShareToolDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
}
