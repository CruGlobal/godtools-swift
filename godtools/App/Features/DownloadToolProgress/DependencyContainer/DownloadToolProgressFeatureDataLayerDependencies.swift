//
//  DownloadToolProgressFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DownloadToolProgressFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getDownloadToolProgressInterfaceStringsRepositoryInterface() -> GetDownloadToolProgressInterfaceStringsRepositoryInterface {
        return GetDownloadToolProgressInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
}
