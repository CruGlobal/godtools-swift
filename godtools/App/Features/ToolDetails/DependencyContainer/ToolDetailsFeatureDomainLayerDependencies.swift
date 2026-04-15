//
//  ToolDetailsFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolDetailsFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolDetailsFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolDetailsFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getToolDetailsLearnToShareToolIsAvailableUseCase() -> GetToolDetailsLearnToShareToolIsAvailableUseCase {
        return GetToolDetailsLearnToShareToolIsAvailableUseCase(
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }

    func getToolDetailsMediaUseCase() -> GetToolDetailsMediaUseCase {
        return GetToolDetailsMediaUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            attachmentsRepository: coreDataLayer.getAttachmentsRepository()
        )
    }
    
    func getToolDetailsStringsUseCase() -> GetToolDetailsStringsUseCase {
        return GetToolDetailsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
        
    func getToolDetailsUseCase() -> GetToolDetailsUseCase {
        return GetToolDetailsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translationsRepository: coreDataLayer.getTranslationsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName(),
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository()
        )
    }
}
