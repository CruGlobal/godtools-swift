//
//  ToolsFilterDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolsFilterDiContainer {
    
    let dataLayer: ToolsFilterDataLayerDependencies
    let domainLayer: ToolsFilterDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = ToolsFilterDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolsFilterDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
