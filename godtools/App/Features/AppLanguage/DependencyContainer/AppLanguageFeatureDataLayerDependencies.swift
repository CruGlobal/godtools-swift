//
//  AppLanguageFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppLanguageFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    private func getAppLanguagesRepository() -> AppLanguagesRepository {
        return AppLanguagesRepository()
    }
    
    func getUserAppLanguageCache() -> RealmUserAppLanguageCache {
        return RealmUserAppLanguageCache(
            realmDatabase: coreDataLayer.getSharedRealmDatabase()
        )
    }
    
    private func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        return UserAppLanguageRepository(
            cache: getUserAppLanguageCache()
        )
    }
    
    // MARK: - Domain Interface
    
    func getAppLanguageRepositoryInterface() -> GetAppLanguageRepositoryInterface {
        return GetAppLanguageRepository(
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getAppLanguagesListRepositoryInterface() -> GetAppLanguagesListRepositoryInterface {
        return GetAppLanguagesListRepository(
            appLanguagesRepository: getAppLanguagesRepository(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName()
        )
    }
    
    func getAppLanguagesRepositoryInterface() -> GetAppLanguagesRepositoryInterface {
        return GetAppLanguagesRepository(
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getDeviceAppLanguageRepositoryInterface() -> GetDeviceAppLanguageRepositoryInterface {
        return GetDeviceAppLanguageRepository(
            deviceSystemLanguage: coreDataLayer.getDeviceSystemLanguage()
        )
    }
    
    func getLanguageSettingsInterfaceStringsRepositoryInterface() -> GetLanguageSettingsInterfaceStringsRepositoryInterface {
        return GetLanguageSettingsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName()
        )
    }
    
    func getSetUserPreferredAppLanguageRepositoryInterface() -> SetUserPreferredAppLanguageRepositoryInterface {
        return SetUserPreferredAppLanguageRepository(
            userAppLanguageRepository: getUserAppLanguageRepository()
        )
    }
    
    func getUserPreferredAppLanguageRepositoryInterface() -> GetUserPreferredAppLanguageRepositoryInterface {
        return GetUserPreferredAppLanguageRepository(
            userAppLanguageRepository: getUserAppLanguageRepository()
        )
    }
}
