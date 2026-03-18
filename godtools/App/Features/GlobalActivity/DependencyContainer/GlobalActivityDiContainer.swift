//
//  GlobalActivityDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GlobalActivityDiContainer {
    
    let dataLayer: GlobalActivityDataLayerDependencies
    let domainLayer: GlobalActivityDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = GlobalActivityDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = GlobalActivityDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
