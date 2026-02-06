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
    
    func getStoreInitialFavoritedTools() -> StoreInitialFavoritedToolsInterface {
        return StoreInitialFavoritedTools(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
}
