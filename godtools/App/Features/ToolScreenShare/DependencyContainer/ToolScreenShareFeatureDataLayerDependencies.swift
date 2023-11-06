//
//  ToolScreenShareFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getToolScreenShareTutorialInterfaceStringsRepositoryInterface() -> GetToolScreenShareTutorialInterfaceStringsRepositoryInterface {
        return GetToolScreenShareTutorialInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareTutorialRepositoryInterface() -> GetToolScreenShareTutorialRepositoryInterface {
        return GetToolScreenShareTutorialRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
