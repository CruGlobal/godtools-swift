//
//  FavoritesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FavoritesDiContainer: Sendable {
    
    let dataLayer: FavoritesDataLayerDependencies
    let domainLayer: FavoritesDomainLayerDependencies
    
    init(dataLayer: FavoritesDataLayerDependencies, domainLayer: FavoritesDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
