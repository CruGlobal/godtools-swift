//
//  LearnToShareToolDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getLearnToShareToolInterfaceStringsRepositoryInterface() -> GetLearnToShareToolInterfaceStringsRepositoryInterface {
        return GetLearnToShareToolInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getLearnToShareToolTutorialItemsRepositoryInterface() -> GetLearnToShareToolTutorialItemsRepositoryInterface {
        return GetLearnToShareToolTutorialItemsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
