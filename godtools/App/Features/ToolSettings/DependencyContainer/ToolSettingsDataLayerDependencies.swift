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
    
    func getToolSettingsInterfaceStringsRepositoryInterface() -> GetToolSettingsInterfaceStringsRepositoryInterface {
        return GetToolSettingsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface() -> GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface {
        return GetToolSettingsToolLanguagesListInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolSettingsToolLanguagesRepositoryInterface() -> GetToolSettingsToolLanguagesRepositoryInterface {
        return GetToolSettingsToolLanguagesRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName(),
            localeLanguageScriptName: coreDataLayer.getLocaleLanguageScriptName()
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
