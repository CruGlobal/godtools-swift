//
//  ToolSettingsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolSettingsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ToolSettingsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ToolSettingsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getToolSettingsStringsUseCase() -> GetToolSettingsStringsUseCase {
        return GetToolSettingsStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListStringsUseCase() -> GetToolSettingsToolLanguagesListStringsUseCase {
        return GetToolSettingsToolLanguagesListStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListUseCase() -> GetToolSettingsToolLanguagesListUseCase {
        return GetToolSettingsToolLanguagesListUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getToolSettingsUseCase() -> GetToolSettingsUseCase {
        return GetToolSettingsUseCase(
            translationsRepository: core.dataLayer.getTranslationsRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName()
        )
    }
}
