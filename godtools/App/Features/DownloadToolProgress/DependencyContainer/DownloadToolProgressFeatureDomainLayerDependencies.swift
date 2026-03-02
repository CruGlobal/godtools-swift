//
//  DownloadToolProgressFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DownloadToolProgressFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: DownloadToolProgressFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: DownloadToolProgressFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getDownloadToolProgressStringsUseCase() -> GetDownloadToolProgressStringsUseCase {
        return GetDownloadToolProgressStringsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
}
