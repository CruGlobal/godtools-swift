//
//  ToolsFilterFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolsFilterFeatureDiContainer {
    
    let dataLayer: ToolsFilterFeatureDataLayerDependencies
    let domainLayer: ToolsFilterFeatureDomainLayerDependencies
    
    // TODO: Eventually coreDomainLayer: AppDomainLayerDependencies should not be injected here once ToolsFilterDomainLayer no longer needs to depend on these use cases. ~Levi
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = ToolsFilterFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        // TODO: Eventually coreDataLayer: coreDataLayer and coreDomainLayer: AppDomainLayerDependencies should not be injected here. ~Levi
        domainLayer = ToolsFilterFeatureDomainLayerDependencies(dataLayer: dataLayer, coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer)
    }
}
