//
//  DashboardDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

@MainActor
final class DashboardDiContainer {
    
    let dataLayer: DashboardDataLayerDependencies
    let domainLayer: DashboardDomainLayerDependencies
    
    init(dataLayer: DashboardDataLayerDependencies, domainLayer: DashboardDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
