//
//  ToolScreenShareQRCodeFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareQRCodeFeatureDiContainer {
    
    let dataLayer: ToolScreenShareQRCodeFeatureDataLayerDependencies
    let domainLayer: ToolScreenShareQRCodeFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = ToolScreenShareQRCodeFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolScreenShareQRCodeFeatureDomainLayerDependencies(dataLayer: dataLayer)
    }
}
