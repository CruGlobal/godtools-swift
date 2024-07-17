//
//  SpotlightToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDomainLayerDependencies {
    
    private let dataLayer: SpotlightToolsDataLayerDependencies
    
    init(dataLayer: SpotlightToolsDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getSpotlightToolsUseCase() -> GetSpotlightToolsUseCase {
        return GetSpotlightToolsUseCase(
            getSpotlightToolsRepository: dataLayer.getSpotlightToolsRepository()
        )
    }
}
