//
//  ToolScreenShareDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareDiContainer {
    
    let dataLayer: ToolScreenShareDataLayerDependencies
    let domainLayer: ToolScreenShareDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = ToolScreenShareDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = ToolScreenShareDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
