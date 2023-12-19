//
//  SharablesDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SharablesDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getSharablesRepositoryInterface() -> GetSharablesRepositoryInterface {
        return GetSharablesRepository(
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
}
