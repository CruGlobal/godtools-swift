//
//  FavoritesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FavoritesDiContainer {
    
    let dataLayer: FavoritesDataLayerDependencies
    let domainLayer: FavoritesDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = FavoritesDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = FavoritesDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
