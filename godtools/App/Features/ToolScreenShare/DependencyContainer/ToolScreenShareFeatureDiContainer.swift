//
//  ToolScreenShareFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareFeatureDiContainer {
    
    let dataLayer: ToolScreenShareFeatureDataLayerDependencies
    let domainLayer: ToolScreenShareFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = ToolScreenShareFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolScreenShareFeatureDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
