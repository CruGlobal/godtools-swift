//
//  DeferredDeepLinkDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DeferredDeepLinkDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: DeferredDeepLinkDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: DeferredDeepLinkDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getDeferredDeepLinkModalStringsUseCase() -> GetDeferredDeepLinkModalStringsUseCase {
        return GetDeferredDeepLinkModalStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
