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
    
    func getToolSettingsRepository() -> ToolSettingsRepository {
        return ToolSettingsRepository(
            cache: RealmToolSettingsCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase()
            )
        )
    }
    
    // MARK: - Domain Interface
    
    func getDeleteToolSettingsParallelLanguageRepositoryInterface() -> DeleteToolSettingsParallelLanguageRepositoryInterface {
        return DeleteToolSettingsParallelLanguageRepository(
            toolSettingsRepository: getToolSettingsRepository()
        )
    }
    
    func getShareToolInterfaceStringsRepositoryInterface() -> GetShareToolInterfaceStringsRepositoryInterface {
        return GetShareToolInterfaceStringsRepository(
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
            toolSettingsRepository: getToolSettingsRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
        )
    }
    
    func getToolSettingsParallelLanguageRepositoryInterface() -> GetToolSettingsParallelLanguageRepositoryInterface {
        return GetToolSettingsParallelLanguageRepository(
            toolSettingsRepository: getToolSettingsRepository(),
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
    
    func getStoreToolSettingsParallelLanguageRepositoryInterface() -> StoreToolSettingsParallelLanguageRepositoryInterface {
        return StoreToolSettingsParallelLanguageRepository(
            toolSettingsRepository: getToolSettingsRepository()
        )
    }
    
    func getStoreToolSettingsPrimaryLanguageRepositoryInterface() -> StoreToolSettingsPrimaryLanguageRepositoryInterface {
        return StoreToolSettingsPrimaryLanguageRepository(
            toolSettingsRepository: getToolSettingsRepository()
        )
    }
}
