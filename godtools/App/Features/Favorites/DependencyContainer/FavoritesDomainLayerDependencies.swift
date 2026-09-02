//
//  FavoritesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FavoritesDomainLayerDependencies: Sendable {
    
    private let core: AppCoreDiContainer
    private let dataLayer: FavoritesDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: FavoritesDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getConfirmRemoveToolFromFavoritesStringsUseCase() -> GetConfirmRemoveToolFromFavoritesStringsUseCase {
        return GetConfirmRemoveToolFromFavoritesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName()
        )
    }
    
    func getDownloadLatestToolsForFavoritedToolsUseCase() -> DownloadLatestToolsForFavoritedToolsUseCase {
        return DownloadLatestToolsForFavoritedToolsUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            toolDownloader: core.dataLayer.getToolDownloader()
        )
    }
    
    func getFavoritesStringsUseCase() -> GetFavoritesStringsUseCase {
        return GetFavoritesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getRemoveFavoritedToolUseCase() -> RemoveFavoritedToolUseCase {
        return RemoveFavoritedToolUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getReorderFavoritedToolUseCase() -> ReorderFavoritedToolUseCase {
        return ReorderFavoritedToolUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getStoreInitialFavoritedToolsUseCase() -> StoreInitialFavoritedToolsUseCase {
        return StoreInitialFavoritedToolsUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToggleToolFavoritedUseCase() -> ToggleToolFavoritedUseCase {
        return ToggleToolFavoritedUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToolIsFavoritedUseCase() -> GetToolIsFavoritedUseCase {
        return GetToolIsFavoritedUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getYourFavoritedToolsUseCase() -> GetYourFavoritedToolsUseCase {
        return GetYourFavoritedToolsUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName(),
            getTranslatedToolCategory: core.domainLayer.supporting.getTranslatedToolCategory(),
            getToolListItemStrings: core.domainLayer.supporting.getToolListItemStrings()
        )
    }
}
