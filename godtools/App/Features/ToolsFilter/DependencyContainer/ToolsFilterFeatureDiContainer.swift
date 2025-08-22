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
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        dataLayer = ToolsFilterFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolsFilterFeatureDomainLayerDependencies(dataLayer: dataLayer)
    }
}
