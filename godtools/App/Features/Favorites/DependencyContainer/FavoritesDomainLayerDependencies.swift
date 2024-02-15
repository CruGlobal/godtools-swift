//
//  FavoritesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FavoritesDomainLayerDependencies {
    
    private let dataLayer: FavoritesDataLayerDependencies
    
    init(dataLayer: FavoritesDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewFavoritesUseCase() -> ViewFavoritesUseCase {
        return ViewFavoritesUseCase(
            getInterfaceStringsRepository: dataLayer.getFavoritesInterfaceStringsRepositoryInterface()
        )
    }
}
