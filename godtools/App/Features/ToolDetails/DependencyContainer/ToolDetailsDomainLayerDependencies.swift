//
//  ToolDetailsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolDetailsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ToolDetailsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ToolDetailsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getToolDetailsLearnToShareToolIsAvailableUseCase() -> GetToolDetailsLearnToShareToolIsAvailableUseCase {
        return GetToolDetailsLearnToShareToolIsAvailableUseCase(
            translationsRepository: core.dataLayer.getTranslationsRepository()
        )
    }

    func getToolDetailsMediaUseCase() -> GetToolDetailsMediaUseCase {
        return GetToolDetailsMediaUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            attachmentsRepository: core.dataLayer.getAttachmentsRepository()
        )
    }
    
    func getToolDetailsStringsUseCase() -> GetToolDetailsStringsUseCase {
        return GetToolDetailsStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
        
    func getToolDetailsUseCase() -> GetToolDetailsUseCase {
        return GetToolDetailsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            translationsRepository: core.dataLayer.getTranslationsRepository(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName(),
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository()
        )
    }
}
