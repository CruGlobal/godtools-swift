//
//  DeferredDeepLinkDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DeferredDeepLinkDomainLayerDependencies {
    
    private let dataLayer: DeferredDeepLinkDataLayerDependencies
    
    init(dataLayer: DeferredDeepLinkDataLayerDependencies) {
        self.dataLayer = dataLayer
    }
    
    func getDeferredDeepLinkModalInterfaceStringsUseCase() -> GetDeferredDeepLinkModalInterfaceStringsUseCase {
        return GetDeferredDeepLinkModalInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getDeferredDeepLinkModalInterfaceStringsRepositoryInterface()
        )
    }
}
