//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication

class AppDataLayerDependencies {
    
    private let sharedAppBuild: AppBuild
    private let sharedAppConfig: AppConfig
    private let sharedInfoPlist: InfoPlist
    private let sharedRealmDatabase: RealmDatabase
    private let sharedIgnoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    private let sharedAnalytics: AnalyticsContainer
    
    init(appBuild: AppBuild, appConfig: AppConfig, infoPlist: InfoPlist, realmDatabase: RealmDatabase) {
        
        sharedAppBuild = appBuild
        sharedAppConfig = appConfig
        sharedInfoPlist = infoPlist
        sharedRealmDatabase = realmDatabase
        
        sharedAnalytics = AnalyticsContainer(
            appsFlyerAnalytics: AppsFlyerAnalytics(appsFlyer: AppsFlyer.shared, loggingEnabled: appBuild.configuration == .analyticsLogging),
            firebaseAnalytics: FirebaseAnalytics(appBuild: appBuild, loggingEnabled: appBuild.configuration == .analyticsLogging),
            snowplowAnalytics: SnowplowAnalytics(config: appConfig, loggingEnabled: appBuild.configuration == .analyticsLogging)
        )
    }
    
    func getAnalytics() -> AnalyticsContainer {
        return sharedAnalytics
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
    
    func getCruOktaAuthentication() -> CruOktaAuthentication {
        return CruOktaAuthentication.getNewAuthenticationInstance(appBuild: sharedAppBuild)
    }
    
    func getDeepLinkingService() -> DeepLinkingService {
        return DeepLinkingService(
            manifest: GodToolsDeepLinkingManifest()
        )
    }
    
    func getEmailSignUpService() -> EmailSignUpService {
        return EmailSignUpService(
            api: EmailSignUpApi(ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmEmailSignUpsCache(realmDatabase: sharedRealmDatabase)
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
    
    func getFollowUpsService() -> FollowUpsService {
        
        let api = FollowUpsApi(
            baseUrl: getAppConfig().mobileContentApiBaseUrl,
            ignoreCacheSession: sharedIgnoreCacheSession
        )
        
        let cache = FailedFollowUpsCache(
            realmDatabase: sharedRealmDatabase
        )
        
        return FollowUpsService(
            api: api,
            cache: cache
        )
    }
    
    func getGlobalAnalyticsRepository() -> GlobalAnalyticsRepository {
        return GlobalAnalyticsRepository(
            api:  MobileContentGlobalAnalyticsApi(
                baseUrl: getAppConfig().mobileContentApiBaseUrl,
                ignoreCacheSession: sharedIgnoreCacheSession
            ),
            cache: GlobalAnalyticsUserDefaultsCache()
        )
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
    
    func getMobileContentAuthTokenKeychainAccessor() -> MobileContentAuthTokenKeychainAccessor {
        return MobileContentAuthTokenKeychainAccessor()
    }
    
    func getMobileContentAuthTokenRepository() -> MobileContentAuthTokenRepository {
        return MobileContentAuthTokenRepository(
            api: MobileContentAuthTokenAPI(
                config: getAppConfig(),
                ignoreCacheSession: sharedIgnoreCacheSession
            ),
            cache: MobileContentAuthTokenCache(
                mobileContentAuthTokenKeychainAccessor: getMobileContentAuthTokenKeychainAccessor()
            )
        )
    }
    
    func getMobileContentApiAuthSession() -> MobileContentApiAuthSession {
        return MobileContentApiAuthSession(
            ignoreCacheSession: sharedIgnoreCacheSession,
            mobileContentAuthTokenRepository: getMobileContentAuthTokenRepository(),
            userAuthentication: getUserAuthentication()
        )
    }
    
    private func getResourcesFileCache() -> ResourcesSHA256FileCache {
        return ResourcesSHA256FileCache(realmDatabase: sharedRealmDatabase)
    }
    
    func getResourcesRepository() -> ResourcesRepository {
        
        let sync = RealmResourcesCacheSync(
            realmDatabase: sharedRealmDatabase,
            trackDownloadedTranslationsRepository: getTrackDownloadedTranslationsRepository()
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
    
    func getUserAuthentication() -> UserAuthentication {
        return UserAuthentication(cruOktaAuthentication: getCruOktaAuthentication())
    }
    
    func getUserDetailsRepository() -> UserDetailsRepository {
        return UserDetailsRepository(
            api: UserDetailsAPI(
                config: getAppConfig(),
                ignoreCacheSession: sharedIgnoreCacheSession,
                mobileContentApiAuthSession: getMobileContentApiAuthSession()
            ),
            cache: RealmUserDetailsCache(
                realmDatabase: sharedRealmDatabase,
                userDetailsSync: RealmUserDetailsCacheSync(realmDatabase: sharedRealmDatabase),
                authTokenRepository: getMobileContentAuthTokenRepository()
            )
        )
    }
}
