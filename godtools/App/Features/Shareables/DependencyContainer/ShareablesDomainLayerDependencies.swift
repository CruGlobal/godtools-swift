//
//  ShareablesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ShareablesDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: ShareablesDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: ShareablesDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getReviewShareShareableStringsUseCase() -> GetReviewShareShareableStringsUseCase {
        return GetReviewShareShareableStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShareableImageUseCase() -> GetShareableImageUseCase {
        return GetShareableImageUseCase(
            resourcesFileCache: coreDataLayer.getResourcesFileCache()
        )
    }
    
    func getShareablesUseCase() -> GetShareablesUseCase {
        return GetShareablesUseCase(
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
    
    func getTrackShareShareableTapUseCase() -> TrackShareShareableTapUseCase {
        return TrackShareShareableTapUseCase(
            trackActionAnalytics: coreDataLayer.getAnalytics().trackActionAnalytics,
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }
}
