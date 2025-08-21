//
//  SpotlightToolsDomainInterfaceDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDomainInterfaceDependencies {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    private let dataLayer: SpotlightToolsDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: SpotlightToolsDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
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
