//
//  ShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ShareToolDiContainer {
        
    private let dataLayer: ShareToolDataLayerDependencies
    
    let domainLayer: ShareToolDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        let dataLayer = ShareToolDataLayerDependencies(coreDataLayer: core.dataLayer)
        
        self.dataLayer = dataLayer
        domainLayer = ShareToolDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
