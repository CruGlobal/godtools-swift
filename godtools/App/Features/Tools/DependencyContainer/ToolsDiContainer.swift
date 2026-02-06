//
//  ToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

class ToolsDiContainer {
        
    private let dataLayer: ToolsDataLayerDependencies
    
    let domainLayer: ToolsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        self.dataLayer = ToolsDataLayerDependencies(coreDataLayer: coreDataLayer)
        self.domainLayer = ToolsDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer, coreDomainLayer: coreDomainLayer)
    }
}
