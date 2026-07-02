//
//  ShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ShareToolDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ShareToolDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ShareToolDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getShareToolQRCodeStringsUseCase() -> GetShareToolQRCodeStringsUseCase {
        return GetShareToolQRCodeStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolStringsUseCase() -> GetShareToolStringsUseCase {
        return GetShareToolStringsUseCase(
            getShareToolUrl: getShareToolUrl(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolQRCodeUseCase() -> ShareToolQRCodeUseCase {
        return ShareToolQRCodeUseCase(
            getShareToolUrl: getShareToolUrl()
        )
    }
    
    private func getShareToolUrl() -> GetShareToolUrl {
        return GetShareToolUrl(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository()
        )
    }
}
