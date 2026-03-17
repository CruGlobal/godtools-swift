//
//  ToolDetailsFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolDetailsFeatureDiContainer {
    
    let dataLayer: ToolDetailsFeatureDataLayerDependencies
    let domainLayer: ToolDetailsFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = ToolDetailsFeatureDataLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer)
        domainLayer = ToolDetailsFeatureDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
