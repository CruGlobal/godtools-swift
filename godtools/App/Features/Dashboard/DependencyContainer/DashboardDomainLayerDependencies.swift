//
//  DashboardDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class DashboardDomainLayerDependencies {
    
    private let dataLayer: DashboardDataLayerDependencies
    
    init(dataLayer: DashboardDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getDownloadLatestToolsForFavoritedToolsUseCase() -> DownloadLatestToolsForFavoritedToolsUseCase {
        return DownloadLatestToolsForFavoritedToolsUseCase(
            latestToolDownloader: dataLayer.getFavoritedToolsLatestToolDownloaderInterface()
        )
    }
    
    func getViewDashboardUseCase() -> ViewDashboardUseCase {
        return ViewDashboardUseCase(
            getInterfaceStringsRepository: dataLayer.getDashboardInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewToolsUseCase() -> ViewToolsUseCase {
        return ViewToolsUseCase(
            getInterfaceStringsRepository: dataLayer.getToolsInterfaceStringsRepository(),
            getToolsRepository: dataLayer.getToolsRepository()
        )
    }
}
