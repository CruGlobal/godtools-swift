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
    
    func getAppLanguagesRepository(realmDatabase: RealmDatabase? = nil, sync: AppLanguagesRepositorySyncInterface? = nil) -> AppLanguagesRepository {
        
        let cache = RealmAppLanguagesCache(
            realmDatabase: realmDatabase ?? coreDataLayer.getSharedRealmDatabase()
        )
        
        let sync: AppLanguagesRepositorySyncInterface = sync ?? AppLanguagesRepositorySync(api: AppLanguagesApi(), cache: cache)
        
        return AppLanguagesRepository(
            cache: cache,
            sync: sync
        )
    }
    
    private func getDownloadedLanguagesRepository() -> DownloadedLanguagesRepository {
        return DownloadedLanguagesRepository(cache: getRealmDownloadedLanguagesCache())
    }
    
    func getToolLanguageDownloader() -> ToolLanguageDownloader {
        return ToolLanguageDownloader(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            toolDownloader: coreDataLayer.getToolDownloader(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository()
        )
    }
    
    private func getRealmDownloadedLanguagesCache() -> RealmDownloadedLanguagesCache {
        return RealmDownloadedLanguagesCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
    }
    
    func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        return UserAppLanguageRepository(
            cache: RealmUserAppLanguageCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
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
    
    func getAppLanguageRepository() -> GetAppLanguageRepositoryInterface {
        return GetAppLanguageRepository(
            userAppLanguageRepository: getUserAppLanguageRepository()
        )
    }
    
    func getAppLanguagesInterfaceStringsRepositoryInterface() -> GetAppLanguagesInterfaceStringsRepositoryInterface {
        return GetAppLanguagesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getConfirmAppLanguageInterfaceStringsRepositoryInterface() -> GetConfirmAppLanguageInterfaceStringsRepositoryInterface {
        return GetConfirmAppLanguageInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
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
    
    func getDownloadedLanguagesListRepositoryInterface() -> GetDownloadedLanguagesListRepositoryInterface {
        return GetDownloadedLanguagesListRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository()
        )
    }
    
    func getDownloadToolLanguageRepositoryInterface() -> DownloadToolLanguageRepositoryInterface {
        return DownloadToolLanguageRepository(
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            toolLanguageDownloader: getToolLanguageDownloader()
        )
    }
    
    func getLanguageSettingsInterfaceStringsRepositoryInterface() -> GetLanguageSettingsInterfaceStringsRepositoryInterface {
        return GetLanguageSettingsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository(),
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getRemoveDownloadedToolLanguageRepositoryInterface() -> RemoveDownloadedToolLanguageRepositoryInterface {
        return RemoveDownloadedToolLanguageRepository(
            downloadedLanguagesRepository: getDownloadedLanguagesRepository()
        )
    }
    
    func getSearchAppLanguageInAppLanguageListRepository() -> SearchAppLanguageInAppLanguagesListRepositoryInterface {
        return SearchAppLanguageInAppLanguagesListRepository(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSearchLanguageInDownloadableLanguagesRepositoryInterface() -> SearchLanguageInDownloadableLanguagesRepositoryInterface {
        return SearchLanguageInDownloadableLanguagesRepository(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSetUserPreferredAppLanguageRepositoryInterface() -> SetUserPreferredAppLanguageRepositoryInterface {
        return SetUserPreferredAppLanguageRepository(
            userAppLanguageRepository: getUserAppLanguageRepository()
        )
    }
    
    func getStoreInitialAppLanguage() -> StoreInitialAppLanguageInterface {
        return StoreInitialAppLanguage(
            deviceSystemLanguage: coreDataLayer.getDeviceSystemLanguage(),
            userAppLanguageRepository: getUserAppLanguageRepository(),
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
}
