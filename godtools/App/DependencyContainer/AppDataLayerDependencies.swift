//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppDataLayerDependencies {
    
    private let sharedAppConfig: AppConfig
    private let sharedInfoPlist: InfoPlist
    private let sharedRealmDatabase: RealmDatabase = RealmDatabase()
    private let sharedIgnoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    
    init(appConfig: AppConfig, infoPlist: InfoPlist) {
        
        sharedAppConfig = appConfig
        sharedInfoPlist = infoPlist
    }
    
    func getAppConfig() -> AppConfig {
        return sharedAppConfig
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
        return AttachmentsRepository(
            api: MobileContentAttachmentsApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmAttachmentsCache(realmDatabase: sharedRealmDatabase),
            resourcesFileCache: getResourcesFileCache(),
            bundle: AttachmentsBundleCache()
        )
    }
    
    func getDeepLinkingService() -> DeepLinkingService {
        return DeepLinkingService(
            manifest: GodToolsDeepLinkingManifest()
        )
    }
    
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository {
        return FavoritedResourcesRepository(
            cache: FavoritedResourcesCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getFavoritingToolMessageCache() -> FavoritingToolMessageCache {
        return FavoritingToolMessageCache(userDefaultsCache: sharedUserDefaultsCache)
    }
    
    func getInfoPlist() -> InfoPlist {
        return sharedInfoPlist
    }

    func getLanguageSettingsRepository() -> LanguageSettingsRepository {
        return LanguageSettingsRepository(
            cache: LanguageSettingsCache()
        )
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        
        let sync = RealmLanguagesCacheSync(realmDatabase: sharedRealmDatabase)
        
        let api = MobileContentLanguagesApi(
            config: getAppConfig(),
            ignoreCacheSession: sharedIgnoreCacheSession
        )
        
        let cache = RealmLanguagesCache(
            realmDatabase: sharedRealmDatabase,
            languagesSync: sync
        )
        
        return LanguagesRepository(
            api: api,
            cache: cache
        )
    }
    
    func getLaunchCountRepository() -> LaunchCountRepository {
        return LaunchCountRepository(
            cache: LaunchCountCache()
        )
    }
    
    func getLocalizationServices() -> LocalizationServices {
        return LocalizationServices()
    }
    
    private func getResourcesFileCache() -> ResourcesSHA256FileCache {
        return ResourcesSHA256FileCache(realmDatabase: sharedRealmDatabase)
    }
    
    func getResourcesRepository() -> ResourcesRepository {
        
        let sync = RealmResourcesCacheSync(
            realmDatabase: sharedRealmDatabase,
            translationsRepository: getTranslationsRepository()
        )
        
        let api = MobileContentResourcesApi(
            config: getAppConfig(),
            ignoreCacheSession: sharedIgnoreCacheSession
        )
        
        let cache = RealmResourcesCache(
            realmDatabase: sharedRealmDatabase,
            resourcesSync: sync
        )
        
        return ResourcesRepository(
            api: api,
            cache: cache,
            attachmentsRepository: getAttachmentsRepository(),
            translationsRepository: getTranslationsRepository(),
            languagesRepository: getLanguagesRepository()
        )
    }
    
    func getSharedAppsFlyer() -> AppsFlyer {
        return AppsFlyer.shared
    }
    
    func getTrackDownloadedTranslationsRepository() -> TrackDownloadedTranslationsRepository {
        return TrackDownloadedTranslationsRepository(
            cache: TrackDownloadedTranslationsCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getTranslationsRepository() -> TranslationsRepository {        
        return TranslationsRepository(
            infoPlist: getInfoPlist(),
            api: MobileContentTranslationsApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmTranslationsCache(realmDatabase: sharedRealmDatabase),
            resourcesFileCache: getResourcesFileCache(),
            trackDownloadedTranslationsRepository: getTrackDownloadedTranslationsRepository()
        )
    }
}
