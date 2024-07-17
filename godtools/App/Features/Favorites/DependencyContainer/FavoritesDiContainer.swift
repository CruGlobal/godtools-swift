//
//  FavoritesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FavoritesDiContainer {
    
    let dataLayer: FavoritesDataLayerDependencies
    let domainLayer: FavoritesDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = FavoritesDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = FavoritesDomainLayerDependencies(dataLayer: dataLayer)
    }
}
