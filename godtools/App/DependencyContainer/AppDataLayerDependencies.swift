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

class AppDataLayerDependencies: DataLayerDependenciesInterface {
    
    enum WebSocketType {
        case starscream
        case urlSession
    }
    
    private static let defaultWebSocketType: WebSocketType = .urlSession
    
    private let sharedAppBuild: AppBuild
    private let sharedAppConfig: AppConfig
    private let sharedUrlSessionPriority: URLSessionPriority = URLSessionPriority()
    private let sharedRequestSender: RequestSender
    private let sharedRealmDatabase: RealmDatabase
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    private let sharedAnalytics: AnalyticsContainer
    private let firebaseEnabled: Bool
    
    init(appBuild: AppBuild, appConfig: AppConfig, realmDatabase: RealmDatabase, firebaseEnabled: Bool, urlSessionEnabled: Bool) {
        
        sharedAppBuild = appBuild
        sharedAppConfig = appConfig
        sharedRealmDatabase = realmDatabase
        self.firebaseEnabled = firebaseEnabled
        
        sharedAnalytics = AnalyticsContainer(
            firebaseAnalytics: FirebaseAnalytics(appBuild: appBuild, loggingEnabled: appBuild.configuration == .analyticsLogging)
        )
        
        if urlSessionEnabled {
            sharedRequestSender = RequestSender()
        }
        else {
            sharedRequestSender = DoesNotSendUrlRequestSender()
        }
    }
    
    // MARK: - Data Layer Classes
    
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
    
    private func getArticleAemCache() -> ArticleAemCache {
        return ArticleAemCache(
            realmDatabase: sharedRealmDatabase,
            articleWebArchiver: ArticleWebArchiver(
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getSharedRequestSender()
            )
        )
    }
    
    private func getArticleAemDownloader() -> ArticleAemDownloader {
        return ArticleAemDownloader(
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getSharedRequestSender()
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
                realmDatabase: sharedRealmDatabase
            ),
            userDefaultsCache: getUserDefaultsCache()
        )
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
        return AttachmentsRepository(
            api: MobileContentAttachmentsApi(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getSharedRequestSender()
            ),
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
            api: EmailSignUpApi(
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getSharedRequestSender()
            ),
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
    
    func getSharedFirebaseMessaging() -> FirebaseMessaging {
        return FirebaseMessaging.shared
    }
    
    func getFollowUpsService() -> FollowUpsService {
        
        let api = FollowUpsApi(
            baseUrl: getAppConfig().getMobileContentApiBaseUrl(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getSharedRequestSender()
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
        return InfoPlist()
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        
        let api = MobileContentLanguagesApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getSharedRequestSender()
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
                requestSender: getSharedRequestSender()
            ),
            cache: MobileContentAuthTokenCache(
                mobileContentAuthTokenKeychainAccessor: getMobileContentAuthTokenKeychainAccessor(),
                realmCache: RealmMobileContentAuthTokenCache(realmDatabase: sharedRealmDatabase)
            )
        )
    }
    
    func getMobileContentApiAuthSession() -> MobileContentApiAuthSession {
        return MobileContentApiAuthSession(
            requestSender: getSharedRequestSender(),
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
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getSharedRequestSender()
        )
        
        let cache = RealmResourcesCache(
            realmDatabase: sharedRealmDatabase,
            resourcesSync: sync
        )
        
        return ResourcesRepository(
            api: api,
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
                requestSender: getSharedRequestSender()
            ),
            failedResourceViewsCache: FailedResourceViewsCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    func getSearchBarInterfaceStringsRepositoryInterface() -> GetSearchBarInterfaceStringsRepositoryInterface {
        return GetSearchBarInterfaceStringsRepository(
            localizationServices: getLocalizationServices()
        )
    }
    
    func getSharedUrlSessionPriority() -> URLSessionPriority {
        return sharedUrlSessionPriority
    }
    
    func getSharedRealmDatabase() -> RealmDatabase {
        return sharedRealmDatabase
    }
    
    func getSharedRequestSender() -> RequestSender {
        return sharedRequestSender
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
            api: MobileContentTranslationsApi(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getSharedRequestSender()
            ),
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
                .facebook: FacebookLimitedLogin(
                    configuration: FacebookLimitedLoginConfiguration(
                        permissions: ["email"]
                    )
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
            urlSessionPriority: getSharedUrlSessionPriority(),
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
    
    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return sharedUserDefaultsCache
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
    
    func getNewWebSocket(url: URL) -> WebSocketInterface {
        
        switch Self.defaultWebSocketType {
        case .starscream:
            return StarscreamWebSocket(url: url)
        case .urlSession:
            return URLSessionWebSocket(url: url)
        }
    }
}
