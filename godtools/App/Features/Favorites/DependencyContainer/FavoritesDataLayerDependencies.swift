//
//  FavoritesDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FavoritesDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
}
