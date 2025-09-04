//
//  DeferredDeepLinkDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DeferredDeepLinkDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getDeferredDeepLinkModalInterfaceStringsRepositoryInterface() -> GetDeferredDeepLinkModalInterfaceStringsRepositoryInterface {
        return GetDeferredDeepLinkInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
