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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = ToolDetailsDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = ToolDetailsDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
