//
//  DownloadToolProgressDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class DownloadToolProgressDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: DownloadToolProgressDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: DownloadToolProgressDataLayerDependencies) {
        
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
