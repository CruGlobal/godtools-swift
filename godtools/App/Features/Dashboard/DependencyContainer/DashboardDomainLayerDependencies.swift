//
//  DashboardDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class DashboardDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: DashboardDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: DashboardDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getDashboardStringsUseCase() -> GetDashboardStringsUseCase {
        return GetDashboardStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
