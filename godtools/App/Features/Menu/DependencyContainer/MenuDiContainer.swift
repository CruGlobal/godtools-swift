//
//  MenuDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class MenuDiContainer {
    
    let dataLayer: MenuDataLayerDependencies
    let domainLayer: MenuDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = MenuDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = MenuDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
