//
//  SharablesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SharablesDomainLayerDependencies {
    
    private let dataLayer: SharablesDataLayerDependencies
    
    init(dataLayer: SharablesDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getSharablesUseCase() -> GetSharablesUseCase {
        return GetSharablesUseCase(
            getSharablesRepository: dataLayer.getSharablesRepositoryInterface()
        )
    }
}
