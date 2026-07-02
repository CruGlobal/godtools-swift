//
//  GlobalActivityDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GlobalActivityDiContainer {
    
    let dataLayer: GlobalActivityDataLayerDependencies
    let domainLayer: GlobalActivityDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = GlobalActivityDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = GlobalActivityDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
