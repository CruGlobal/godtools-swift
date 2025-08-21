//
//  SpotlightToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDiContainer {
    
    let dataLayer: SpotlightToolsDataLayerDependenciesInterface
    let domainInterfaceLayer: SpotlightToolsDomainInterfaceDependencies
    let domainLayer: SpotlightToolsDomainLayerDependencies
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: SpotlightToolsDataLayerDependenciesInterface, domainInterfaceLayer: SpotlightToolsDomainInterfaceDependencies) {
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
        domainLayer = SpotlightToolsDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
