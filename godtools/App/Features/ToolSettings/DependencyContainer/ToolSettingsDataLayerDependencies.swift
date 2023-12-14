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
    
    private func getToolSettingsRepository() -> ToolSettingsRepository {
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
    
    func getToolSettingsInterfaceStringsRepositoryInterface() -> GetToolSettingsInterfaceStringsRepositoryInterface {
        return GetToolSettingsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsPrimaryLanguageRepositoryInterface() -> GetToolSettingsPrimaryLanguageRepositoryInterface {
        return GetToolSettingsPrimaryLanguageRepository(
            toolSettingsRepository: getToolSettingsRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
        )
    }
    
    func getToolSettingsParallelLanguageRepositoryInterface() -> GetToolSettingsParallelLanguageRepositoryInterface {
        return GetToolSettingsParallelLanguageRepository(
            toolSettingsRepository: getToolSettingsRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
        )
    }
    
    func getToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface() -> GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface {
        return GetToolSettingsToolLanguagesListInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListRepositoryInterface() -> GetToolSettingsToolLanguagesListRepositoryInterface {
        return GetToolSettingsToolLanguagesListRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
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
