//
//  SpotlightToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDiContainer {
    
    let dataLayer: SpotlightToolsDataLayerDependencies
    let domainLayer: SpotlightToolsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        self.dataLayer = SpotlightToolsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = SpotlightToolsDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
