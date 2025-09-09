//
//  DeferredDeepLinkDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DeferredDeepLinkDiContainer {
    
    let dataLayer: DeferredDeepLinkDataLayerDependencies
    let domainLayer: DeferredDeepLinkDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = DeferredDeepLinkDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = DeferredDeepLinkDomainLayerDependencies(dataLayer: dataLayer)
    }
}
