//
//  ShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ShareToolDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: ShareToolDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: ShareToolDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getShareToolQRCodeStringsUseCase() -> GetShareToolQRCodeStringsUseCase {
        return GetShareToolQRCodeStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolStringsUseCase() -> GetShareToolStringsUseCase {
        return GetShareToolStringsUseCase(
            getShareToolUrl: getShareToolUrl(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolQRCodeUseCase() -> ShareToolQRCodeUseCase {
        return ShareToolQRCodeUseCase(
            getShareToolUrl: getShareToolUrl()
        )
    }
    
    private func getShareToolUrl() -> GetShareToolUrl {
        return GetShareToolUrl(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository()
        )
    }
}
