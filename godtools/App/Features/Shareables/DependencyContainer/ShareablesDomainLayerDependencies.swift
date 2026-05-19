//
//  ShareablesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ShareablesDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ShareablesDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ShareablesDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getReviewShareShareableStringsUseCase() -> GetReviewShareShareableStringsUseCase {
        return GetReviewShareShareableStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getShareableImageUseCase() -> GetShareableImageUseCase {
        return GetShareableImageUseCase(
            resourcesFileCache: core.dataLayer.getResourcesFileCache()
        )
    }
    
    func getShareablesUseCase() -> GetShareablesUseCase {
        return GetShareablesUseCase(
            translationsRepository: core.dataLayer.getTranslationsRepository()
        )
    }
    
    func getTrackShareShareableTapUseCase() -> TrackShareShareableTapUseCase {
        return TrackShareShareableTapUseCase(
            trackActionAnalytics: core.dataLayer.getAnalytics().trackActionAnalytics,
            resourcesRepository: core.dataLayer.getResourcesRepository()
        )
    }
}
