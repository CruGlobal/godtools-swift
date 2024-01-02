//
//  DashboardDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class DashboardDiContainer {
    
    let dataLayer: DashboardDataLayerDependencies
    let domainLayer: DashboardDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = DashboardDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        domainLayer = DashboardDomainLayerDependencies(dataLayer: dataLayer)
    }
}
