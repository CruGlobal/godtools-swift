//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// TODO: Remove these imports once TheKeyOauthClient is replaced. ~Levi
import TheKeyOAuthSwift
import GTMAppAuth

class AppDiContainer {
        
    private let legacyRealmMigration: LegacyRealmMigration
    private let realmDatabase: RealmDatabase
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache = ResourcesSHA256FileCache() // TODO: Make private. ~Levi
    private let sharedIgnoringCacheSession: SharedIgnoreCacheSession = SharedIgnoreCacheSession()
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let translationsApi: TranslationsApiType
    private let realmResourcesCache: RealmResourcesCache
    private let resourcesDownloader: ResourcesDownloader
    private let resourcesCache: ResourcesCache
    private let languagesCache: RealmLanguagesCache
    private let attachmentsFileCache: AttachmentsFileCache
    private let attachmentsDownloader: AttachmentsDownloader
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    private let resourcesCleanUp: ResourcesCleanUp
    private let initialDeviceResourcesLoader: InitialDeviceResourcesLoader
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()

    let config: ConfigType
    let crashReporting: CrashReportingType
    let userAuthentication: UserAuthenticationType
    let loginClient: TheKeyOAuthClient
    let translationsFileCache: TranslationsFileCache
    let translationDownloader: TranslationDownloader
    let favoritedResourcesCache: FavoritedResourcesCache
    let downloadedLanguagesCache: DownloadedLanguagesCache
    let favoritedResourceTranslationDownloader: FavoritedResourceTranslationDownloader
    let initialDataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let languageDirectionService: LanguageDirectionService
    let languageTranslationsDownloader: LanguageTranslationsDownloader
    let isNewUserService: IsNewUserService
    let analytics: AnalyticsContainer
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let localizationServices: LocalizationServices = LocalizationServices()
    let deviceLanguage: DeviceLanguageType = DeviceLanguage()
    let fetchTranslationManifestsViewModel: FetchTranslationManifestsViewModel
    let globalActivityServices: GlobalActivityServices
    let followUpsService: FollowUpsService
    let viewsService: ViewsService
    let shortcutItemsService: ShortcutItemsService
    let deepLinkingService: DeepLinkingServiceType
    let deviceAttachmentBanners: DeviceAttachmentBanners = DeviceAttachmentBanners()
    let favoritingToolMessageCache: FavoritingToolMessageCache
    let emailSignUpService: EmailSignUpService
    let appsFlyer: AppsFlyerType
    let firebaseInAppMessaging: FirebaseInAppMessagingType
        
    required init() {
        
        config = AppConfig()
        
        crashReporting = FirebaseCrashlyticsService()
        
        userAuthentication = TheKeyUserAuthentication()
        
        loginClient = TheKeyOAuthClient.shared
        
        realmDatabase = RealmDatabase()

        languagesApi = LanguagesApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        resourcesApi = ResourcesApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        translationsApi = TranslationsApi(config: config, sharedSession: sharedIgnoringCacheSession)
                        
        realmResourcesCache = RealmResourcesCache(realmDatabase: realmDatabase)
        
        resourcesDownloader = ResourcesDownloader(languagesApi: languagesApi, resourcesApi: resourcesApi)
        
        resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        
        languagesCache = RealmLanguagesCache(realmDatabase: realmDatabase)
        
        translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, resourcesCache: resourcesCache, sha256FileCache: resourcesSHA256FileCache)
                
        translationDownloader = TranslationDownloader(realmDatabase: realmDatabase, resourcesCache: resourcesCache, translationsApi: translationsApi, translationsFileCache: translationsFileCache)
        
        attachmentsFileCache = AttachmentsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
        
        attachmentsDownloader = AttachmentsDownloader(attachmentsFileCache: attachmentsFileCache, sharedSession: sharedIgnoringCacheSession)
           
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
        
        favoritedResourcesCache = FavoritedResourcesCache(realmDatabase: realmDatabase)
              
        downloadedLanguagesCache = DownloadedLanguagesCache(realmDatabase: realmDatabase)
                
        favoritedResourceTranslationDownloader = FavoritedResourceTranslationDownloader(
            realmDatabase: realmDatabase,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache,
            translationDownloader: translationDownloader
        )
        
        legacyRealmMigration = LegacyRealmMigration(
            realmDatabase: realmDatabase,
            languageSettingsCache: languageSettingsCache,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache,
            failedFollowUpsCache: failedFollowUpsCache
        )
        
        resourcesCleanUp = ResourcesCleanUp(
            realmDatabase: realmDatabase,
            translationsFileCache: translationsFileCache,
            resourcesSHA256FileCache: resourcesSHA256FileCache,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache
        )
        
        initialDeviceResourcesLoader = InitialDeviceResourcesLoader(
            realmDatabase: realmDatabase,
            legacyRealmMigration: legacyRealmMigration,
            attachmentsFileCache: attachmentsFileCache,
            translationsFileCache: translationsFileCache,
            realmResourcesCache: realmResourcesCache,
            favoritedResourcesCache: favoritedResourcesCache,
            languagesCache: languagesCache,
            deviceLanguage: deviceLanguage,
            languageSettingsCache: languageSettingsCache
        )
        
        initialDataDownloader = InitialDataDownloader(
            realmDatabase: realmDatabase,
            initialDeviceResourcesLoader: initialDeviceResourcesLoader,
            resourcesDownloader: resourcesDownloader,
            realmResourcesCache: realmResourcesCache,
            resourcesCache: resourcesCache,
            languagesCache: languagesCache,
            resourcesCleanUp: resourcesCleanUp,
            attachmentsDownloader: attachmentsDownloader,
            languageSettingsCache: languageSettingsCache,
            favoritedResourceTranslationDownloader: favoritedResourceTranslationDownloader
        )
        
        languageSettingsService = LanguageSettingsService(
            dataDownloader: initialDataDownloader,
            languageSettingsCache: languageSettingsCache
        )
        
        languageDirectionService = LanguageDirectionService(languageSettings: languageSettingsService)
        
        languageTranslationsDownloader = LanguageTranslationsDownloader(
            realmDatabase: realmDatabase,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            downloadedLanguagesCache: downloadedLanguagesCache,
            translationDownloader: translationDownloader
        )
        
        isNewUserService = IsNewUserService(
            isNewUserCache: IsNewUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache),
            determineNewUser: DetermineNewUserIfPrimaryLanguageSet(languageSettingsCache: languageSettingsCache)
        )
        
        deepLinkingService = DeepLinkingService(
            deepLinkParsers: [ToolDeepLinkParser(), ToolsDeepLinkParser(), LessonDeepLinkParser(), LessonsDeepLinkParser(), ArticleDeepLinkParser()],
            loggingEnabled: config.isDebug
        )
        
        appsFlyer = AppsFlyer(config: config, deepLinkingService: deepLinkingService)
        
        firebaseInAppMessaging = FirebaseInAppMessaging()
                
        let analyticsLoggingEnabled: Bool = config.build == .analyticsLogging
        analytics = AnalyticsContainer(
            appsFlyerAnalytics: AppsFlyerAnalytics(appsFlyer: appsFlyer, loggingEnabled: analyticsLoggingEnabled),
            firebaseAnalytics: FirebaseAnalytics(config: config, keyAuthClient: loginClient, languageSettingsService: languageSettingsService, loggingEnabled: analyticsLoggingEnabled),
            snowplowAnalytics: SnowplowAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: analyticsLoggingEnabled)
        )
                                                          
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                           
        fetchTranslationManifestsViewModel = FetchTranslationManifestsViewModel(
            realmDatabase: realmDatabase,
            resourcesCache: initialDataDownloader.resourcesCache,
            languageSettingsService: languageSettingsService,
            translationsFileCache: translationsFileCache
        )
        
        globalActivityServices = GlobalActivityServices(config: config, sharedSession: sharedIgnoringCacheSession)
        
        followUpsService = FollowUpsService(config: config, sharedSession: sharedIgnoringCacheSession, failedFollowUpsCache: failedFollowUpsCache)
        
        viewsService = ViewsService(config: config, realmDatabase: realmDatabase, sharedSession: sharedIgnoringCacheSession)
        
        shortcutItemsService = ShortcutItemsService(
            realmDatabase: realmDatabase,
            dataDownloader: initialDataDownloader,
            languageSettingsCache: languageSettingsCache,
            favoritedResourcesCache: favoritedResourcesCache
        )
        
        favoritingToolMessageCache = FavoritingToolMessageCache(userDefaultsCache: sharedUserDefaultsCache)
        
        emailSignUpService = EmailSignUpService(sharedSession: sharedIgnoringCacheSession, realmDatabase: realmDatabase, userAuthentication: userAuthentication)
    }
    
    func getArticleAemRepository() -> ArticleAemRepository {
        return ArticleAemRepository(
            downloader: ArticleAemDownloader(sharedSession: sharedIgnoringCacheSession),
            cache: ArticleAemCache(realmDatabase: realmDatabase, webArchiverSession: sharedIgnoringCacheSession)
        )
    }
    
    func getArticleManifestAemRepository() -> ArticleManifestAemRepository {
        return ArticleManifestAemRepository(
            downloader: ArticleAemDownloader(sharedSession: sharedIgnoringCacheSession),
            cache: ArticleAemCache(realmDatabase: realmDatabase, webArchiverSession: sharedIgnoringCacheSession),
            realmDatabase: realmDatabase
        )
    }
    
    func getCardJumpService() -> CardJumpService {
        return CardJumpService(cardJumpCache: CardJumpUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache))
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getFontService() -> FontService {
        return FontService(languageSettings: languageSettingsService)
    }
    
    func getMobileContentAnalytics() -> MobileContentAnalytics {
        return MobileContentAnalytics(analytics: analytics)
    }
    
    func getMobileContentNodeParser() -> MobileContentXmlNodeParser {
        return MobileContentXmlNodeParser()
    }
    
    func getMobileContentRenderer(manifestFilename: String, flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageModel) -> MobileContentMultiplatformRenderer {
        
        // TODO: Change return type to MobileContentRendererType. ~Levi
        
        let multiplatformParser: MobileContentMultiplatformParser? = MobileContentMultiplatformParser(
            manifestFilename: manifestFilename,
            sha256FileCache: resourcesSHA256FileCache
        )
        
        // TODO: Don't force unwrap multiplatform parser. Return node parser?   ~Levi
        let multiplatformRenderer = MobileContentMultiplatformRenderer(
            flowDelegate: flowDelegate,
            multiplatformParser: multiplatformParser!,
            resource: resource,
            language: language
        )
        
        return multiplatformRenderer
    }
    
    func getToolTrainingTipsOnboardingViews() -> ToolTrainingTipsOnboardingViewsService {
        return ToolTrainingTipsOnboardingViewsService(
            cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache(userDefaultsCache: sharedUserDefaultsCache)
        )
    }
    
    func getViewedTrainingTipsService() -> ViewedTrainingTipsService {
        return ViewedTrainingTipsService(
            cache: ViewedTrainingTipsUserDefaultsCache(sharedUserDefaults: sharedUserDefaultsCache)
        )
    }
    
    var firebaseConfiguration: FirebaseConfiguration {
        return FirebaseConfiguration(config: config)
    }
    
    var googleAdwordsAnalytics: GoogleAdwordsAnalytics {
        return GoogleAdwordsAnalytics(config: config)
    }
    
    var toolOpenedAnalytics: ToolOpenedAnalytics {
        return ToolOpenedAnalytics(appsFlyerAnalytics: analytics.appsFlyerAnalytics)
    }
    
    var exitLinkAnalytics: ExitLinkAnalytics {
        return ExitLinkAnalytics(firebaseAnalytics: analytics.firebaseAnalytics)
    }
    
    var onboardingTutorialAvailability: OnboardingTutorialAvailabilityType {
        return OnboardingTutorialAvailability(
            tutorialAvailability: tutorialAvailability,
            onboardingTutorialViewedCache: onboardingTutorialViewedCache,
            isNewUserCache: isNewUserService.isNewUserCache
        )
    }
    
    var onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType {
        return OnboardingTutorialViewedUserDefaultsCache()
    }
    
    var tutorialSupportedLanguages: SupportedLanguagesType {
        return TutorialSupportedLanguages()
    }
    
    var tutorialAvailability: TutorialAvailabilityType {
        return TutorialAvailability(deviceLanguage: deviceLanguage, tutorialSupportedLanguages: tutorialSupportedLanguages)
    }
    
    var tractRemoteShareSubscriber: TractRemoteShareSubscriber {
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteShareSubscriber(
            config: config,
            webSocket: webSocket,
            webSocketChannelSubscriber: ActionCableChannelSubscriber(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    var tractRemoteSharePublisher: TractRemoteSharePublisher {
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteSharePublisher(
            config: config,
            webSocket: webSocket,
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    var tractRemoteShareURLBuilder: TractRemoteShareURLBuilder {
        return TractRemoteShareURLBuilder()
    }
    
    var shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache {
        return ShareToolScreenTutorialNumberOfViewsCache(sharedUserDefaultsCache: sharedUserDefaultsCache)
    }
    
    var learnToShareToolItemsProvider: LearnToShareToolItemsProviderType {
        return InMemoryLearnToShareToolItems(localization: localizationServices)
    }
    
    var tutorialItemsProvider: TutorialItemProviderType {
        return TutorialItemProvider(localizationServices: localizationServices, deviceLanguage: deviceLanguage)
    }
}
