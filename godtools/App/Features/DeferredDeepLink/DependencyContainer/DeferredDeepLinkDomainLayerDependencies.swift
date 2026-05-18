//
//  DeferredDeepLinkDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class DeferredDeepLinkDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: DeferredDeepLinkDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: DeferredDeepLinkDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getDeferredDeepLinkModalStringsUseCase() -> GetDeferredDeepLinkModalStringsUseCase {
        return GetDeferredDeepLinkModalStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getDeferredDeepLinkUseCase() -> GetDeferredDeepLinkUseCase {
        return GetDeferredDeepLinkUseCase(
            deepLinkService: core.dataLayer.getDeepLinkingService(),
            dynalinkDeferredDeepLink: dataLayer.getDynalinkDeferredDeepLink(),
            launchCountRepository: core.dataLayer.getLaunchCountRepository()
        )
    }
}
