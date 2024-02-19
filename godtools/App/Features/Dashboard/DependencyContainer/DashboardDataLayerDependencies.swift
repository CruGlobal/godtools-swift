//
//  DashboardDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class DashboardDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getDashboardInterfaceStringsRepositoryInterface() -> GetDashboardInterfaceStringsRepositoryInterface {
        return GetDashboardInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getFavoritedToolsLatestToolDownloaderInterface() -> FavoritedToolsLatestToolDownloaderInterface {
        return FavoritedToolsLatestToolDownloader(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            toolDownloader: coreDataLayer.getToolDownloader()
        )
    }
    
    func getToolsInterfaceStringsRepository() -> GetToolsInterfaceStringsRepositoryInterface {
        return GetToolsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolsRepository() -> GetToolsRepositoryInterface {
        return GetToolsRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolCategory: coreDataLayer.getTranslatedToolCategory(),
            getToolListItemInterfaceStringsRepository: coreDataLayer.getToolListItemInterfaceStringsRepository(),
            getTranslatedToolLanguageAvailability: coreDataLayer.getTranslatedToolLanguageAvailability()
        )
    }
}
