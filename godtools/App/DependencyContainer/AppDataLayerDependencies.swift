//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication
import LocalizationServices

class AppDataLayerDependencies {
    
    enum WebSocketType {
        case starscream
        case urlSession
    }
    
    private static let defaultWebSocketType: WebSocketType = .urlSession
    
    private let sharedAppBuild: AppBuild
    private let sharedAppConfig: AppConfig
    private let sharedInfoPlist: InfoPlist
    private let sharedRealmDatabase: RealmDatabase
    private let sharedIgnoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    private let sharedAnalytics: AnalyticsContainer
    private let firebaseEnabled: Bool
    
    init(appBuild: AppBuild, appConfig: AppConfig, infoPlist: InfoPlist, realmDatabase: RealmDatabase, firebaseEnabled: Bool) {
        
        sharedAppBuild = appBuild
        sharedAppConfig = appConfig
        sharedInfoPlist = infoPlist
        sharedRealmDatabase = realmDatabase
        self.firebaseEnabled = firebaseEnabled
        
        sharedAnalytics = AnalyticsContainer(
            firebaseAnalytics: FirebaseAnalytics(appBuild: appBuild, loggingEnabled: appBuild.configuration == .analyticsLogging)
        )
    }
    
    // MARK: - Data Layer Classes
    
    func getAccountInterfaceStringsRepositoryInterface() -> GetAccountInterfaceStringsRepositoryInterface {
        return GetAccountInterfaceStringsRepository(
            localizationServices: getLocalizationServices()
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
    
    func getAppMessaging() -> AppMessagingInterface {
        
        guard firebaseEnabled else {
            return DisabledInAppMessaging()
        }
        
        return FirebaseInAppMessaging.shared
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
    
    func getDeviceSystemLanguage() -> DeviceSystemLanguageInterface {
        return DeviceSystemLanguage()
    }
    
    func getEmailSignUpService() -> EmailSignUpService {
        return EmailSignUpService(
            api: EmailSignUpApi(ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmEmailSignUpsCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository {
        return FavoritedResourcesRepository(
            cache: RealmFavoritedResourcesCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getFavoritingToolMessageCache() -> FavoritingToolMessageCache {
        return FavoritingToolMessageCache(userDefaultsCache: sharedUserDefaultsCache)
    }
    
    func getFirebaseMessaging() -> FirebaseMessaging {
        return FirebaseMessaging()
    }
    
    func getFollowUpsService() -> FollowUpsService {
        
        let api = FollowUpsApi(
            baseUrl: getAppConfig().getMobileContentApiBaseUrl(),
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
    
    func getInfoPlist() -> InfoPlist {
        return sharedInfoPlist
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        
        let api = MobileContentLanguagesApi(
            config: getAppConfig(),
            ignoreCacheSession: sharedIgnoreCacheSession,
            priorityRequestSender: getSharedPriorityRequestSender()
        )
        
        let cache = RealmLanguagesCache(
            realmDatabase: sharedRealmDatabase,
            languagesSync: RealmLanguagesCacheSync(realmDatabase: sharedRealmDatabase)
        )
        
        return LanguagesRepository(
            api: api,
            cache: cache
        )
    }
    
    func getLessonListItemProgressRepository() -> GetLessonListItemProgressRepository {
        return GetLessonListItemProgressRepository(
            lessonProgressRepository: getUserLessonProgressRepository(),
            userCountersRepository: getUserCountersRepository(),
            localizationServices: getLocalizationServices(), 
            getTranslatedPercentage: getTranslatedPercentage()
        )
    }
    
    func getLocalizationLanguageNameRepository() -> LocalizationLanguageNameRepository {
        return LocalizationLanguageNameRepository(
            localizationServices: getLocalizationServices()
        )
    }
    
    func getLocalizationServices() -> LocalizationServices {
        return LocalizationServices(localizableStringsFilesBundle: Bundle.main)
    }
    
    func getMenuInterfaceStringsRepositoryInterface() -> GetMenuInterfaceStringsRepositoryInterface {
        return GetMenuInterfaceStringsRepository(
            localizationServices: getLocalizationServices(),
            infoPlist: getInfoPlist()
        )
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
    
    func getOptInOnboardingBannerEnabledRepository() -> OptInOnboardingBannerEnabledRepository {
        return OptInOnboardingBannerEnabledRepository(
            cache: OptInOnboardingBannerEnabledCache()
        )
    }
    
    func getRemoteConfigRepository() -> RemoteConfigRepository {
        
        return RemoteConfigRepository(
            remoteDatabase: firebaseEnabled ? FirebaseRemoteConfigWrapper() : DisabledRemoteConfigDatabase()
        )
    }
    
    func getResourcesFileCache() -> ResourcesSHA256FileCache {
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
    
    func getSearchBarInterfaceStringsRepositoryInterface() -> GetSearchBarInterfaceStringsRepositoryInterface {
        return GetSearchBarInterfaceStringsRepository(
            localizationServices: getLocalizationServices()
        )
    }
    
    func getSharedIgnoreCacheSession() -> IgnoreCacheSession {
        return sharedIgnoreCacheSession
    }
    
    func getSharedLaunchCountRepository() -> LaunchCountRepository {
        return LaunchCountRepository.shared
    }
    
    func getSharedPriorityRequestSender() -> PriorityRequestSenderInterface {
        return TempPriorityRequestSender.shared
    }
    
    func getSharedRealmDatabase() -> RealmDatabase {
        return sharedRealmDatabase
    }
    
    func getSharedUserDefaultsCache() -> SharedUserDefaultsCache {
        return sharedUserDefaultsCache
    }
    
    func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        return StringWithLocaleCount()
    }
    
    func getToolDownloader() -> ToolDownloader {
        return ToolDownloader(
            resourcesRepository: getResourcesRepository(),
            languagesRepository: getLanguagesRepository(),
            translationsRepository: getTranslationsRepository(),
            attachmentsRepository: getAttachmentsRepository(),
            articleManifestAemRepository: getArticleManifestAemRepository()
        )
    }
    
    func getToolListItemInterfaceStringsRepository() -> GetToolListItemInterfaceStringsRepository {
        return GetToolListItemInterfaceStringsRepository(
            localizationServices: getLocalizationServices()
        )
    }
    
    func getTrackDownloadedTranslationsRepository() -> TrackDownloadedTranslationsRepository {
        return TrackDownloadedTranslationsRepository(
            cache: TrackDownloadedTranslationsCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        return GetTranslatedLanguageName(
            localizationLanguageNameRepository: getLocalizationLanguageNameRepository(),
            localeLanguageName: LocaleLanguageName(),
            localeRegionName: LocaleLanguageRegionName(),
            localeScriptName: LocaleLanguageScriptName()
        )
    }
    
    func getTranslatedNumberCount() -> GetTranslatedNumberCount {
        return GetTranslatedNumberCount()
    }
    
    func getTranslatedPercentage() -> GetTranslatedPercentage {
        return GetTranslatedPercentage()
    }
    
    func getTranslatedToolCategory() -> GetTranslatedToolCategory {
        return GetTranslatedToolCategory(
            localizationServices: getLocalizationServices(),
            resourcesRepository: getResourcesRepository()
        )
    }
    
    func getTranslatedToolName() -> GetTranslatedToolName {
        return GetTranslatedToolName(
            resourcesRepository: getResourcesRepository(),
            translationsRepository: getTranslationsRepository()
        )
    }
    
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability {
        return GetTranslatedToolLanguageAvailability(
            localizationServices: getLocalizationServices(),
            resourcesRepository: getResourcesRepository(),
            languagesRepository: getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName()
        )
    }
    
    func getTranslationsRepository() -> TranslationsRepository {        
        return TranslationsRepository(
            infoPlist: getInfoPlist(),
            api: MobileContentTranslationsApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmTranslationsCache(realmDatabase: sharedRealmDatabase),
            resourcesFileCache: getResourcesFileCache(),
            trackDownloadedTranslationsRepository: getTrackDownloadedTranslationsRepository(),
            remoteConfigRepository: getRemoteConfigRepository()
        )
    }
    
    func getTutorialVideoAnalytics() -> TutorialVideoAnalytics {
        return TutorialVideoAnalytics(
            trackActionAnalytics: getAnalytics().trackActionAnalytics
        )
    }

    func getUserAuthentication() -> UserAuthentication {
        
        return UserAuthentication(
            authenticationProviders: [
                .apple: AppleAuthentication(
                    appleUserPersistentStore: AppleUserPersistentStore()
                ),
                .facebook: FacebookAuthentication(
                    configuration: FacebookAuthenticationConfiguration(permissions: ["email"])
                ),
                .google: GoogleAuthentication(
                    configuration: getAppConfig().getGoogleAuthenticationConfiguration()
                )
            ],
            lastAuthenticatedProviderCache: LastAuthenticatedProviderCache(userDefaultsCache: sharedUserDefaultsCache),
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
                authTokenRepository: getMobileContentAuthTokenRepository()
            )
        )
    }
    
    func getUserLessonFiltersRepository() -> UserLessonFiltersRepository {
        return UserLessonFiltersRepository(
            cache: RealmUserLessonFiltersCache(
                realmDatabase: sharedRealmDatabase
            )
        )
    }
    
    func getUserLessonProgressRepository() -> UserLessonProgressRepository {
        return UserLessonProgressRepository(
            cache: RealmUserLessonProgressCache(
                realmDatabase: sharedRealmDatabase
            )
        )
    }
    
    func getWebArchiveQueue() -> WebArchiveQueue {
        return WebArchiveQueue(ignoreCacheSession: sharedIgnoreCacheSession)
    }
    
    func getNewWebSocket(url: URL) -> WebSocketInterface {
        
        switch Self.defaultWebSocketType {
        case .starscream:
            return StarscreamWebSocket(url: url)
        case .urlSession:
            return URLSessionWebSocket(url: url)
        }
    }
}
