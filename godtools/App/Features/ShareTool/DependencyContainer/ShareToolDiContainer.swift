//
//  ShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ShareToolDiContainer {
        
    private let dataLayer: ShareToolDataLayerDependencies
    
    let domainLayer: ShareToolDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        let dataLayer = ShareToolDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        self.dataLayer = dataLayer
        domainLayer = ShareToolDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
