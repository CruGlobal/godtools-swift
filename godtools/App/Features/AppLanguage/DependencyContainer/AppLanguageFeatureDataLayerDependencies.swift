//
//  AppLanguageFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class AppLanguageFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    func getAppLanguagesRepository(sync: AppLanguagesRepositorySyncInterface? = nil) -> AppLanguagesRepository {
        
        let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftAppLanguageDataModelMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmAppLanguageDataModelMapping()
            )
        }
        
        let api = AppLanguagesApi()
        
        let syncInvalidator = SyncInvalidator(
            id: String(describing: AppLanguagesRepositorySync.self),
            timeInterval: .minutes(minute: 15),
            persistence: coreDataLayer.getUserDefaultsCache()
        )
        
        let sync: AppLanguagesRepositorySyncInterface = sync ?? AppLanguagesRepositorySync(
            api: AppLanguagesApi(),
            persistence: persistence,
            syncInvalidator: syncInvalidator
        )
        
        return AppLanguagesRepository(
            externalDataFetch: api,
            persistence: persistence,
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
        return RealmDownloadedLanguagesCache(realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase())
    }
    
    func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        
        let persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftUserAppLanguageDataModelMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmUserAppLanguageDataModelMapping()
            )
        }
        
        let cache = UserAppLanguageCache(persistence: persistence)
        
        return UserAppLanguageRepository(
            cache: cache
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
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    func getDownloadedLanguagesListRepositoryInterface() -> GetDownloadedLanguagesListRepositoryInterface {
        return GetDownloadedLanguagesListRepository(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName()
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
