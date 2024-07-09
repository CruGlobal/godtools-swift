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
    
    func getUserToolSettingsRepository() -> UserToolSettingsRepository {
        return UserToolSettingsRepository(cache: getRealmUserToolSettingsCache())
    }
    
    func getRealmUserToolSettingsCache() -> RealmUserToolSettingsCache {
        return RealmUserToolSettingsCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
    }
    
    // MARK: - Domain Interface
    
    func getPersistUserToolLanguageSettingsRepositoryInterface() -> PersistUserToolLanguageSettingsRepositoryInterface {
        return PersistUserToolLanguageSettingsRepository(
            userToolSettingsRepository: getUserToolSettingsRepository()
        )
    }
    
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
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
        )
    }
    
    func getToolSettingsParallelLanguageRepositoryInterface() -> GetToolSettingsParallelLanguageRepositoryInterface {
        return GetToolSettingsParallelLanguageRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
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
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
        )
    }
}
