//
//  MenuDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class MenuDiContainer {
    
    let dataLayer: MenuDataLayerDependencies
    let domainLayer: MenuDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = MenuDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = MenuDomainLayerDependencies(dataLayer: dataLayer)
    }
}
