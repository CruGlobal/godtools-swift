//
//  ToolSettingsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getShareToolInterfaceStringsRepositoryInterface() -> GetShareToolInterfaceStringsRepositoryInterface {
        return GetShareToolInterfaceStringsRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsInterfaceStringsRepositoryInterface() -> GetToolSettingsInterfaceStringsRepositoryInterface {
        return GetToolSettingsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsPrimaryLanguageRepositoryInterface() -> GetToolSettingsPrimaryLanguageRepositoryInterface {
        return GetToolSettingsPrimaryLanguageRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
        )
    }
    
    func getToolSettingsParallelLanguageRepositoryInterface() -> GetToolSettingsParallelLanguageRepositoryInterface {
        return GetToolSettingsParallelLanguageRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
        )
    }
    
    func getToolSettingsToolHasTipsRepositoryInterface() -> GetToolSettingsToolHasTipsRepositoryInterface {
        return GetToolSettingsToolHasTipsRepository(
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
    
    func getToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface() -> GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface {
        return GetToolSettingsToolLanguagesListInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListRepositoryInterface() -> GetToolSettingsToolLanguagesListRepositoryInterface {
        return GetToolSettingsToolLanguagesListRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
        )
    }
}
