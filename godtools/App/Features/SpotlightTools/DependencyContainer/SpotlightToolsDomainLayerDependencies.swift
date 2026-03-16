//
//  SpotlightToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SpotlightToolsDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: SpotlightToolsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: SpotlightToolsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getSpotlightToolsUseCase() -> GetSpotlightToolsUseCase {
        return GetSpotlightToolsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDomainLayer.supporting.getTranslatedToolName(),
            getTranslatedToolCategory: coreDomainLayer.supporting.getTranslatedToolCategory(),
            getToolListItemStrings: coreDomainLayer.supporting.getToolListItemStrings(),
            getTranslatedToolLanguageAvailability: coreDomainLayer.supporting.getTranslatedToolLanguageAvailability()
        )
    }
}
