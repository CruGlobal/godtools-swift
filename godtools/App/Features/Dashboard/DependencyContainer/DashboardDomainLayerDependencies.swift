//
//  DashboardDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class DashboardDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: DashboardDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: DashboardDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getDashboardStringsUseCase() -> GetDashboardStringsUseCase {
        return GetDashboardStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
