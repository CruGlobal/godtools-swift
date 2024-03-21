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
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getToolDetailsInterfaceStringsRepository() -> GetToolDetailsInterfaceStringsRepositoryInterface {
        return GetToolDetailsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolDetailsLearnToShareToolIsAvailableRepository() -> GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface {
        return GetToolDetailsLearnToShareToolIsAvailableRepository(
            translationsRepository: coreDataLayer.getTranslationsRepository()
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
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
}
