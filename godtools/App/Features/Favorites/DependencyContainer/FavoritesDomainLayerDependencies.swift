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
    
    func getRemoveFavoritedToolUseCase() -> RemoveFavoritedToolUseCase {
        return RemoveFavoritedToolUseCase(
            removeFavoritedToolRepository: dataLayer.getRemoveFavoritedToolRepository()
        )
    }
    
    func getToggleFavoritedToolUseCase() -> ToggleToolFavoritedUseCase {
        return ToggleToolFavoritedUseCase(
            toggleToolFavoritedRepository: dataLayer.getToggleToolFavoritedRepository()
        )
    }
    
    func getToolIsFavoritedUseCase() -> GetToolIsFavoritedUseCase {
        return GetToolIsFavoritedUseCase(
            getToolIsFavoritedRepository: dataLayer.getToolIsFavoritedRepository()
        )
    }
    
    func getViewAllYourFavoritedToolsUseCase() -> ViewAllYourFavoritedToolsUseCase {
        return ViewAllYourFavoritedToolsUseCase(
            getInterfaceStringsRepository: dataLayer.getAllYourFavoritedToolsInterfaceStringsRepository(),
            getFavoritedToolsRepository: dataLayer.getYourFavoritedToolsRepository()
        )
    }
    
    func getViewConfirmRemoveToolFromFavoritesUseCase() -> ViewConfirmRemoveToolFromFavoritesUseCase {
        return ViewConfirmRemoveToolFromFavoritesUseCase(
            interfaceStringsRepository: dataLayer.getConfirmRemoveToolFromFavoritesInterfaceStringsRepository()
        )
    }
    
    func getViewFavoritesUseCase() -> ViewFavoritesUseCase {
        return ViewFavoritesUseCase(
            getInterfaceStringsRepository: dataLayer.getFavoritesInterfaceStringsRepository(),
            getFavoritedToolsRepository: dataLayer.getYourFavoritedToolsRepository()
        )
    }
}
