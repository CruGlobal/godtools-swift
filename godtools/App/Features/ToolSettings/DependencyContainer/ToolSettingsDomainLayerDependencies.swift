//
//  ToolSettingsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolSettingsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolSettingsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getToolSettingsStringsUseCase() -> GetToolSettingsStringsUseCase {
        return GetToolSettingsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListStringsUseCase() -> GetToolSettingsToolLanguagesListStringsUseCase {
        return GetToolSettingsToolLanguagesListStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListUseCase() -> GetToolSettingsToolLanguagesListUseCase {
        return GetToolSettingsToolLanguagesListUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getToolSettingsUseCase() -> GetToolSettingsUseCase {
        return GetToolSettingsUseCase(
            translationsRepository: coreDataLayer.getTranslationsRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName()
        )
    }
}
