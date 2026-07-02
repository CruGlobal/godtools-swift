//
//  DownloadToolProgressDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class DownloadToolProgressDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: DownloadToolProgressDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: DownloadToolProgressDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getDownloadToolProgressStringsUseCase() -> GetDownloadToolProgressStringsUseCase {
        return GetDownloadToolProgressStringsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
}
