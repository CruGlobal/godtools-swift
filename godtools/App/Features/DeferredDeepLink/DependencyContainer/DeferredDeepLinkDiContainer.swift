//
//  DeferredDeepLinkDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@MainActor
final class DeferredDeepLinkDiContainer {
    
    let dataLayer: DeferredDeepLinkDataLayerDependencies
    let domainLayer: DeferredDeepLinkDomainLayerDependencies
    
    init(dataLayer: DeferredDeepLinkDataLayerDependencies, domainLayer: DeferredDeepLinkDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
