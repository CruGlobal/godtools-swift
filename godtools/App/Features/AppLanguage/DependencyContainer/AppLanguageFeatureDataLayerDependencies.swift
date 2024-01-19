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
    
    private func getAppLanguagesCache() -> AppLanguagesCache {
        return AppLanguagesCache()
    }
    
    private func getAppLanguagesRepository() -> AppLanguagesRepository {
        return AppLanguagesRepository(cache: getAppLanguagesCache())
    }
    
    private func getDownloadedLanguagesRepository() -> DownloadedLanguagesRepository {
        return DownloadedLanguagesRepository(cache: getRealmDownloadedLanguagesCache())
    }
    
    func getUserAppLanguageCache() -> RealmUserAppLanguageCache {
        return RealmUserAppLanguageCache(
            realmDatabase: coreDataLayer.getSharedRealmDatabase()
        )
    }
    
    private func getRealmDownloadedLanguagesCache() -> RealmDownloadedLanguagesCache {
        return RealmDownloadedLanguagesCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
    }
    
    private func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        return UserAppLanguageRepository(
            cache: getUserAppLanguageCache()
        )
    }
    
    // MARK: - Domain Interface
    
    func getAppInterfaceLayoutDirectionInterface() -> GetAppInterfaceLayoutDirectionInterface {
        return GetAppInterfaceLayoutDirection(
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getAppLanguagesListRepositoryInterface() -> GetAppLanguagesListRepositoryInterface {
        return GetAppLanguagesListRepository(
            appLanguagesRepository: getAppLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
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
    
    func getDownloadableLanguagesInterfaceStringsRepositoryInterface() -> GetDownloadableLanguagesInterfaceStringsRepositoryInterface {
        return GetDownloadableLanguagesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDownloadableLanguagesListRepositoryInterface() -> GetDownloadableLanguagesListRepositoryInterface {
        return GetDownloadableLanguagesListRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDownloadToolLanguageRepositoryInterface() -> DownloadToolLanguageRepositoryInterface {
        return DownloadToolLanguageRepository(
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
    
    func getLanguageSettingsInterfaceStringsRepositoryInterface() -> GetLanguageSettingsInterfaceStringsRepositoryInterface {
        return GetLanguageSettingsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName(),
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getRemoveDownloadedToolLanguageRepositoryInterface() -> RemoveDownloadedToolLanguageRepositoryInterface {
        return RemoveDownloadedToolLanguageRepository(
            downloadedLanguagesRepository: getDownloadedLanguagesRepository()
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
