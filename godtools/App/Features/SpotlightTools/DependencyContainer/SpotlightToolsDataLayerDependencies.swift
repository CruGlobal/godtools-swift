//
//  SpotlightToolsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getSpotlightToolsRepository() -> GetSpotlightToolsRepositoryInterface {
        return GetSpotlightToolsRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolCategory: coreDataLayer.getTranslatedToolCategory(),
            getToolListItemInterfaceStringsRepository: coreDataLayer.getToolListItemInterfaceStringsRepository(),
            getTranslatedToolLanguageAvailability: coreDataLayer.getTranslatedToolLanguageAvailability()
        )
    }
}
