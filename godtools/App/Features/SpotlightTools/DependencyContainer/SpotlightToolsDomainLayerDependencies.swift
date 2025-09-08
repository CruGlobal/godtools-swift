//
//  SpotlightToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDomainLayerDependencies {
    
    private let domainInterfaceLayer: SpotlightToolsDomainInterfaceDependencies
    
    init(domainInterfaceLayer: SpotlightToolsDomainInterfaceDependencies) {
        
        self.domainInterfaceLayer = domainInterfaceLayer
    }
    
    func getSpotlightToolsUseCase() -> GetSpotlightToolsUseCase {
        return GetSpotlightToolsUseCase(
            getSpotlightToolsRepository: domainInterfaceLayer.getSpotlightToolsRepository()
        )
    }
}
