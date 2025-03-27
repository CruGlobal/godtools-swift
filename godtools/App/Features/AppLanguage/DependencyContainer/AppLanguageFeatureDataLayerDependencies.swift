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
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            cache: RealmToolLanguageDownloaderCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
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
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
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
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
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
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDownloadedLanguagesListRepositoryInterface() -> GetDownloadedLanguagesListRepositoryInterface {
        return GetDownloadedLanguagesListRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
        )
    }
    
    func getDownloadToolLanguageProgress() -> GetDownloadToolLanguageProgressInterface {
        return GetDownloadToolLanguageProgress(
            toolLanguageDownloader: getToolLanguageDownloader(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository()
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
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName(),
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
            userAppLanguageRepository: getUserAppLanguageRepository(),
            userLessonFiltersRepository: coreDataLayer.getUserLessonFiltersRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository()
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
