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
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = SpotlightToolsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = SpotlightToolsDomainLayerDependencies(dataLayer: dataLayer)
    }
}
