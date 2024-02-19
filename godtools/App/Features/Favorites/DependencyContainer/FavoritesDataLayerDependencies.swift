//
//  FavoritesDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FavoritesDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getAllYourFavoritedToolsInterfaceStringsRepository() -> GetAllYourFavoritedToolsInterfaceStringsRepositoryInterface {
        return GetAllYourFavoritedToolsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getConfirmRemoveToolFromFavoritesInterfaceStringsRepository() -> GetConfirmRemoveToolFromFavoritesInterfaceStringsRepositoryInterface {
        return GetConfirmRemoveToolFromFavoritesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName()
        )
    }
    
    func getFavoritesInterfaceStringsRepository() -> GetFavoritesInterfaceStringsRepositoryInterface {
        return GetFavoritesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getRemoveFavoritedToolRepository() -> RemoveFavoritedToolRepositoryInterface {
        return RemoveFavoritedToolRepository(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToggleToolFavoritedRepository() -> ToggleToolFavoritedRepositoryInterface {
        return ToggleToolFavoritedRepository(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToolIsFavoritedRepository() -> GetToolIsFavoritedRepositoryInterface {
        return GetToolIsFavoritedRepository(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getYourFavoritedToolsRepository() -> GetYourFavoritedToolsRepositoryInterface {
        return GetYourFavoritedToolsRepository(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolCategory: coreDataLayer.getTranslatedToolCategory(),
            getToolListItemInterfaceStringsRepository: coreDataLayer.getToolListItemInterfaceStringsRepository(),
            getTranslatedToolLanguageAvailability: coreDataLayer.getTranslatedToolLanguageAvailability()
        )
    }
}
