//
//  SpotlightToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class SpotlightToolsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: SpotlightToolsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: SpotlightToolsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getSpotlightToolsUseCase() -> GetSpotlightToolsUseCase {
        return GetSpotlightToolsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName(),
            getTranslatedToolCategory: core.domainLayer.supporting.getTranslatedToolCategory(),
            getToolListItemStrings: core.domainLayer.supporting.getToolListItemStrings(),
            getTranslatedToolLanguageAvailability: core.domainLayer.supporting.getTranslatedToolLanguageAvailability()
        )
    }
}
