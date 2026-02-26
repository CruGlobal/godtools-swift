//
//  FavoritesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FavoritesDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: FavoritesDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: FavoritesDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getAllYourFavoritedToolsStringsUseCase() -> GetAllYourFavoritedToolsStringsUseCase {
        return GetAllYourFavoritedToolsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getConfirmRemoveToolFromFavoritesStringsUseCase() -> GetConfirmRemoveToolFromFavoritesStringsUseCase {
        return GetConfirmRemoveToolFromFavoritesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName()
        )
    }
    
    func getFavoritesStringsUseCase() -> GetFavoritesStringsUseCase {
        return GetFavoritesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getRemoveFavoritedToolUseCase() -> RemoveFavoritedToolUseCase {
        return RemoveFavoritedToolUseCase(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getReorderFavoritedToolUseCase() -> ReorderFavoritedToolUseCase {
        return ReorderFavoritedToolUseCase(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToggleToolFavoritedUseCase() -> ToggleToolFavoritedUseCase {
        return ToggleToolFavoritedUseCase(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToolIsFavoritedUseCase() -> GetToolIsFavoritedUseCase {
        return GetToolIsFavoritedUseCase(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getYourFavoritedToolsUseCase() -> GetYourFavoritedToolsUseCase {
        return GetYourFavoritedToolsUseCase(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolCategory: coreDataLayer.getTranslatedToolCategory(),
            getToolListItemInterfaceStringsRepository: coreDataLayer.getToolListItemInterfaceStringsRepository()
        )
    }
}
