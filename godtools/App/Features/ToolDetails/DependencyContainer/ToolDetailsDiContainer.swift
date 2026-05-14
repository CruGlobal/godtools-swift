//
//  ToolDetailsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolDetailsDiContainer {
    
    let dataLayer: ToolDetailsDataLayerDependencies
    let domainLayer: ToolDetailsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = ToolDetailsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolDetailsDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
