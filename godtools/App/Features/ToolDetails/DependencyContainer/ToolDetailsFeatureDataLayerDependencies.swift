//
//  ToolDetailsFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolDetailsFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getToolDetailsInterfaceStringsRepository() -> GetToolDetailsInterfaceStringsRepositoryInterface {
        return GetToolDetailsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolDetailsMediaRepository() -> GetToolDetailsMediaRepositoryInterface {
        return GetToolDetailsMediaRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            attachmentsRepository: coreDataLayer.getAttachmentsRepository()
        )
    }
        
    func getToolDetailsRepository() -> GetToolDetailsRepositoryInterface {
        return GetToolDetailsRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translationsRepository: coreDataLayer.getTranslationsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName()
        )
    }
    
    func getToolDetailsToolIsFavoritedRepository() -> GetToolDetailsToolIsFavoritedRepositoryInterface {
        return GetToolDetailsToolIsFavoritedRepository(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
}
