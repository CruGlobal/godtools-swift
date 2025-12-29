//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import SocialAuthentication
import LocalizationServices

class AppDataLayerDependencies {
        
    private let sharedAppConfig: AppConfigInterface
    private let sharedUrlSessionPriority: URLSessionPriority = URLSessionPriority()
    private let sharedLegacyRealmDatabase: LegacyRealmDatabase
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    private let sharedAnalytics: AnalyticsContainer
    
    init(appConfig: AppConfigInterface) {
        
        sharedAppConfig = appConfig
        sharedLegacyRealmDatabase = appConfig.getLegacyRealmDatabase()
        
        sharedAnalytics = AnalyticsContainer(
            firebaseAnalytics: Self.getFirebaseAnalytics(appConfig: appConfig)
        )
    }
    
    private static func getFirebaseAnalytics(appConfig: AppConfigInterface) -> FirebaseAnalyticsInterface {
        
        let firebaseAnalyticsEnabled: Bool = appConfig.analyticsEnabled && appConfig.firebaseEnabled
        
        guard firebaseAnalyticsEnabled else {
            return DisabledFirebaseAnalytics()
        }
        
        return FirebaseAnalytics(
            isDebug: appConfig.isDebug,
            loggingEnabled: appConfig.buildConfig == .analyticsLogging
        )
    }
    
    // MARK: - Data Layer Classes
    
    func getAnalytics() -> AnalyticsContainer {
        return sharedAnalytics
    }
    
    func getAppConfig() -> AppConfigInterface {
        return sharedAppConfig
    }
    
    func getAppMessaging() -> AppMessagingInterface {
        return sharedAppConfig.firebaseEnabled ? FirebaseInAppMessaging.shared : DisabledInAppMessaging()
    }
    
    private func getArticleAemCache() -> ArticleAemCache {
        return ArticleAemCache(
            realmDatabase: getSharedLegacyRealmDatabase(),
            articleWebArchiver: ArticleWebArchiver(
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            )
        )
    }
    
    private func getArticleAemDownloader() -> ArticleAemDownloader {
        return ArticleAemDownloader(
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
    }
    
    func getArticleAemRepository() -> ArticleAemRepository {
        return ArticleAemRepository(
            downloader: getArticleAemDownloader(),
            cache: getArticleAemCache()
        )
    }
    
    func getArticleManifestAemRepository() -> ArticleManifestAemRepository {
        return ArticleManifestAemRepository(
            downloader: getArticleAemDownloader(),
            cache: getArticleAemCache(),
            categoryArticlesCache: RealmCategoryArticlesCache(
                realmDatabase: getSharedLegacyRealmDatabase()
            ),
            userDefaultsCache: getUserDefaultsCache()
        )
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
        return AttachmentsRepository(
            api: MobileContentAttachmentsApi(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            ),
            cache: AttachmentsCache(
                resourcesFileCache: getResourcesFileCache(),
                bundle: AttachmentsBundleCache(),
                realmDatabase: getSharedLegacyRealmDatabase()
            )
        )
    }
    
    func getCompletedTrainingTipRepository() -> CompletedTrainingTipRepository {
        return CompletedTrainingTipRepository(
            cache: RealmCompletedTrainingTipCache(realmDatabase: getSharedLegacyRealmDatabase())
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
            api: EmailSignUpApi(
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            ),
            cache: RealmEmailSignUpsCache(realmDatabase: getSharedLegacyRealmDatabase())
        )
    }
    
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository {
        return FavoritedResourcesRepository(
            cache: RealmFavoritedResourcesCache(realmDatabase: getSharedLegacyRealmDatabase())
        )
    }
    
    func getFavoritingToolMessageCache() -> FavoritingToolMessageCache {
        return FavoritingToolMessageCache(userDefaultsCache: sharedUserDefaultsCache)
    }
    
    func getFirebaseConfiguration() -> FirebaseConfiguration {
        return FirebaseConfiguration(config: getAppConfig())
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getFollowUpsService() -> FollowUpsService {
        
        let api = FollowUpsApi(
            baseUrl: getAppConfig().getMobileContentApiBaseUrl(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = FailedFollowUpsCache(
            realmDatabase: getSharedLegacyRealmDatabase()
        )
        
        return FollowUpsService(
            api: api,
            cache: cache
        )
    }
    
    func getInfoPlist() -> InfoPlist {
        return InfoPlist()
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        
        let api = MobileContentLanguagesApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
                
        return LanguagesRepository(
            api: api,
            cache: LanguagesCache(realmDatabase: getSharedLegacyRealmDatabase())
        )
    }
    
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface {
        return LaunchCountRepository.shared
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
    
    func getLocalizationServices() -> LocalizationServicesInterface {
        return LocalizationServices(
            localizableStringsFilesBundle: Bundle.main,
            isUsingBaseInternationalization: false
        )
    }
    
    func getMobileContentAuthTokenKeychainAccessor() -> MobileContentAuthTokenKeychainAccessor {
        return MobileContentAuthTokenKeychainAccessor()
    }
    
    func getMobileContentAuthTokenRepository() -> MobileContentAuthTokenRepository {
        return MobileContentAuthTokenRepository(
            api: MobileContentAuthTokenAPI(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            ),
            cache: MobileContentAuthTokenCache(
                mobileContentAuthTokenKeychainAccessor: getMobileContentAuthTokenKeychainAccessor(),
                realmCache: RealmMobileContentAuthTokenCache(realmDatabase: getSharedLegacyRealmDatabase())
            )
        )
    }
    
    func getMobileContentApiAuthSession() -> MobileContentApiAuthSession {
        return MobileContentApiAuthSession(
            requestSender: getRequestSender(),
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
            remoteDatabase: sharedAppConfig.firebaseEnabled ? FirebaseRemoteConfigWrapper() : DisabledRemoteConfigDatabase()
        )
    }
    
    func getRequestSender() -> RequestSender {
        return sharedAppConfig.urlRequestsEnabled ? RequestSender() : DoesNotSendUrlRequestSender()
    }
    
    func getResourcesFileCache() -> ResourcesSHA256FileCache {
        return ResourcesSHA256FileCache(realmDatabase: getSharedLegacyRealmDatabase())
    }
    
    func getResourcesRepository() -> ResourcesRepository {
        
        let api = MobileContentResourcesApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = ResourcesCache(
            realmDatabase: getSharedLegacyRealmDatabase(),
            trackDownloadedTranslationsRepository: getTrackDownloadedTranslationsRepository()
        )
        
        return ResourcesRepository(
            api: api,
            realmDatabase: getSharedLegacyRealmDatabase(),
            cache: cache,
            attachmentsRepository: getAttachmentsRepository(),
            languagesRepository: getLanguagesRepository(),
            userDefaultsCache: getUserDefaultsCache()
        )
    }
    
    func getResourceViewsService() -> ResourceViewsService {
        
        return ResourceViewsService(
            resourceViewsApi: MobileContentResourceViewsApi(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            ),
            failedResourceViewsCache: FailedResourceViewsCache(realmDatabase: getSharedLegacyRealmDatabase())
        )
    }
    
    func getSearchBarInterfaceStringsRepositoryInterface() -> GetSearchBarInterfaceStringsRepositoryInterface {
        return GetSearchBarInterfaceStringsRepository(
            localizationServices: getLocalizationServices()
        )
    }
    
    func getSharedFirebaseMessaging() -> FirebaseMessaging {
        return FirebaseMessaging.shared
    }
    
    func getSharedUrlSessionPriority() -> URLSessionPriority {
        return sharedUrlSessionPriority
    }
    
    func getSharedLegacyRealmDatabase() -> LegacyRealmDatabase {
        return sharedLegacyRealmDatabase
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
            cache: TrackDownloadedTranslationsCache(
                realmDatabase: getSharedLegacyRealmDatabase()
            )
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
    
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability {
        return GetTranslatedToolLanguageAvailability(
            localizationServices: getLocalizationServices(),
            resourcesRepository: getResourcesRepository(),
            languagesRepository: getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName()
        )
    }
    
    func getTranslatedToolName() -> GetTranslatedToolName {
        return GetTranslatedToolName(
            resourcesRepository: getResourcesRepository(),
            translationsRepository: getTranslationsRepository()
        )
    }
    
    func getTranslationsRepository() -> TranslationsRepository {        
        return TranslationsRepository(
            infoPlist: getInfoPlist(),
            api: MobileContentTranslationsApi(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            ),
            realmDatabase: getSharedLegacyRealmDatabase(),
            cache: TranslationsCache(realmDatabase: getSharedLegacyRealmDatabase()),
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
                
        var authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface] = Dictionary()
        
        authenticationProviders[.apple] = AppleAuthentication(
            appleUserPersistentStore: AppleUserPersistentStore()
        )
        
        authenticationProviders[.facebook] = FacebookLimitedLogin(
            configuration: FacebookLimitedLoginConfiguration(permissions: ["email"])
        )
        
        if let googleAuthConfiguration = getAppConfig().getGoogleAuthenticationConfiguration() {
            authenticationProviders[.google] = GoogleAuthentication(
                configuration: googleAuthConfiguration
            )
        }
        
        return UserAuthentication(
            authenticationProviders: authenticationProviders,
            lastAuthenticatedProviderCache: LastAuthenticatedProviderCache(userDefaultsCache: sharedUserDefaultsCache),
            mobileContentAuthTokenRepository: getMobileContentAuthTokenRepository()
        )
    }
    
    func getUserCountersRepository() -> UserCountersRepository {
        
        let api = UserCountersAPI(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            mobileContentApiAuthSession: getMobileContentApiAuthSession()
        )
        
        let cache = RealmUserCountersCache(
            realmDatabase: getSharedLegacyRealmDatabase(),
            userCountersSync: RealmUserCountersCacheSync(realmDatabase: getSharedLegacyRealmDatabase())
        )
        
        return UserCountersRepository(
            api: api,
            cache: cache,
            remoteUserCountersSync: RemoteUserCountersSync(api: api, cache: cache)
        )
    }
    
    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return sharedUserDefaultsCache
    }
    
    func getUserLessonFiltersRepository() -> UserLessonFiltersRepository {
        return UserLessonFiltersRepository(
            cache: RealmUserLessonFiltersCache(
                realmDatabase: getSharedLegacyRealmDatabase()
            )
        )
    }
    
    func getUserLessonProgressRepository() -> UserLessonProgressRepository {
        return UserLessonProgressRepository(
            cache: RealmUserLessonProgressCache(
                realmDatabase: getSharedLegacyRealmDatabase()
            )
        )
    }
    
    func getWebSocket(url: URL) -> WebSocketInterface {
        return URLSessionWebSocket(url: url)
    }
}
