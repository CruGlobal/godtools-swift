//
//  TutorialFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TutorialFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getTutorialInterfaceStringsRepositoryInterface() -> GetTutorialInterfaceStringsRepositoryInterface {
        return GetTutorialInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getTutorialRepositoryInterface() -> GetTutorialRepositoryInterface {
        return GetTutorialRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
