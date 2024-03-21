//
//  ShareablesDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ShareablesDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getReviewShareShareableInterfaceStringsRepositoryInterface() -> GetReviewShareShareableInterfaceStringsRepositoryInterface {
        return GetReviewShareShareableInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShareableImageRepositoryInterface() -> GetShareableImageRepositoryInterface {
        return GetShareableImageRepository(
            resourcesFileCache: coreDataLayer.getResourcesFileCache()
        )
    }
    
    func getShareablesRepositoryInterface() -> GetShareablesRepositoryInterface {
        return GetShareablesRepository(
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
    
    func getTrackShareShareableTap() -> TrackShareShareableTapInterface {
        return TrackShareShareableTap(
            trackActionAnalytics: coreDataLayer.getAnalytics().trackActionAnalytics,
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }
}
