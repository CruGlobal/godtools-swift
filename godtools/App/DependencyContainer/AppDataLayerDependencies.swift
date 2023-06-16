//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

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
            firebaseAnalytics: FirebaseAnalytics(appBuild: appBuild, loggingEnabled: appBuild.configuration == .analyticsLogging)
        )
    }
    
    func getAnalytics() -> AnalyticsContainer {
        return sharedAnalytics
    }
    
    func getAppBuild() -> AppBuild {
        return sharedAppBuild
    }
    
    func getAppConfig() -> AppConfig {
        return sharedAppConfig
    }
    
    func getAppleAuthentication() -> AppleAuthentication {
        return AppleAuthentication(
            appleUserPersistentStore: AppleUserPersistentStore()
        )
    }
    
    func getArticleAemRepository() -> ArticleAemRepository {
        return ArticleAemRepository(
            downloader: ArticleAemDownloader(
                ignoreCacheSession: sharedIgnoreCacheSession
            ),
            cache: ArticleAemCache(
                realmDatabase: sharedRealmDatabase,
                webArchiveQueue: getWebArchiveQueue()
            )
        )
    }
    
    func getArticleManifestAemRepository() -> ArticleManifestAemRepository {
        return ArticleManifestAemRepository(
            downloader: ArticleAemDownloader(
                ignoreCacheSession: sharedIgnoreCacheSession
            ),
            cache: ArticleAemCache(
                realmDatabase: sharedRealmDatabase,
                webArchiveQueue: getWebArchiveQueue()
            ),
            categoryArticlesCache: RealmCategoryArticlesCache(
                realmDatabase: sharedRealmDatabase
            )
        )
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
        return AttachmentsRepository(
            api: MobileContentAttachmentsApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmAttachmentsCache(realmDatabase: sharedRealmDatabase),
            resourcesFileCache: getResourcesFileCache(),
            bundle: AttachmentsBundleCache()
        )
    }
    
    func getCompletedTrainingTipRepository() -> CompletedTrainingTipRepository {
        return CompletedTrainingTipRepository(
            cache: RealmCompletedTrainingTipCache(realmDatabase: sharedRealmDatabase)
        )
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
    
    func getFacebookAuthentication() -> FacebookAuthentication {
        return FacebookAuthentication(configuration: FacebookAuthenticationConfiguration(permissions: ["email"]))
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
            cache: RealmGlobalAnalyticsCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getGoogleAuthentication() -> GoogleAuthentication {
        
        return GoogleAuthentication(
            configuration: sharedAppConfig.googleAuthenticationConfiguration
        )
    }
    
    func getInfoPlist() -> InfoPlist {
        return sharedInfoPlist
    }
    
    func getInitialDataDownloader() -> InitialDataDownloader {
        return InitialDataDownloader(
            resourcesRepository: getResourcesRepository()
        )
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
    
    func getLastAuthenticatedProviderCache() -> LastAuthenticatedProviderCache {
        return LastAuthenticatedProviderCache(userDefaultsCache: sharedUserDefaultsCache)
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
                mobileContentAuthTokenKeychainAccessor: getMobileContentAuthTokenKeychainAccessor(),
                realmCache: RealmMobileContentAuthTokenCache(realmDatabase: sharedRealmDatabase)
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
    
    func getOnboardingTutorialViewedRepository() -> OnboardingTutorialViewedRepository {
        return OnboardingTutorialViewedRepository(
            cache: OnboardingTutorialViewedUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache)
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
    
    func getResourceViewsService() -> ResourceViewsService {
        
        return ResourceViewsService(
            resourceViewsApi: MobileContentResourceViewsApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            failedResourceViewsCache: FailedResourceViewsCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getSetupParallelLanguageViewedRepository() -> SetupParallelLanguageViewedRepository {
        return SetupParallelLanguageViewedRepository(
            cache: SetupParallelLanguageViewedUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache)
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
        return UserAuthentication(
            authenticationProviders: [
                .apple: getAppleAuthentication(),
                .facebook: getFacebookAuthentication(),
                .google: getGoogleAuthentication()
            ],
            lastAuthenticatedProviderCache: getLastAuthenticatedProviderCache(),
            mobileContentAuthTokenRepository: getMobileContentAuthTokenRepository()
        )
    }
    
    func getUserCountersRepository() -> UserCountersRepository {
        
        let api = UserCountersAPI(
            config: getAppConfig(),
            ignoreCacheSession: sharedIgnoreCacheSession,
            mobileContentApiAuthSession: getMobileContentApiAuthSession()
        )
        
        let cache = RealmUserCountersCache(
            realmDatabase: sharedRealmDatabase,
            userCountersSync: RealmUserCountersCacheSync(realmDatabase: sharedRealmDatabase)
        )
        
        return UserCountersRepository(
            api: api,
            cache: cache,
            remoteUserCountersSync: RemoteUserCountersSync(api: api, cache: cache)
        )
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
    
    func getViewedTrainingTipsService() -> ViewedTrainingTipsService {
        return ViewedTrainingTipsService(
            cache: ViewedTrainingTipsUserDefaultsCache(sharedUserDefaults: sharedUserDefaultsCache)
        )
    }
    
    func getWebArchiveQueue() -> WebArchiveQueue {
        return WebArchiveQueue(ignoreCacheSession: sharedIgnoreCacheSession)
    }
}
