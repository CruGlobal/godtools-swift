//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import OktaAuthentication

class AppDiContainer {
        
    private let realmDatabase: RealmDatabase = RealmDatabase()
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let sharedIgnoringCacheSession: SharedIgnoreCacheSession = SharedIgnoreCacheSession()
    private let languagesApi: MobileContentLanguagesApi
    private let resourcesApi: ResourcesApiType
    private let translationsApi: MobileContentTranslationsApi
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

    let config: ConfigType = AppConfig()
    let userAuthentication: UserAuthenticationType
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
    let localizationServices: LocalizationServices = LocalizationServices()
    let deviceLanguage: DeviceLanguageType = DeviceLanguage()
    let globalActivityServices: GlobalActivityServices
    let followUpsService: FollowUpsService
    let viewsService: ViewsService
    let shortcutItemsService: ShortcutItemsService
    let deviceAttachmentBanners: DeviceAttachmentBanners = DeviceAttachmentBanners()
    let favoritingToolMessageCache: FavoritingToolMessageCache
    let emailSignUpService: EmailSignUpService
    let appsFlyer: AppsFlyerType
    let firebaseInAppMessaging: FirebaseInAppMessagingType
        
    required init(appDeepLinkingService: DeepLinkingServiceType) {
                        
        let oktaAuthentication: CruOktaAuthentication = OktaAuthenticationConfiguration().configureAndCreateNewOktaAuthentication(config: config)
        userAuthentication = OktaUserAuthentication(oktaAuthentication: oktaAuthentication)
                
        languagesApi = MobileContentLanguagesApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        resourcesApi = ResourcesApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        translationsApi = MobileContentTranslationsApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        resourcesFileCache = ResourcesSHA256FileCache(realmDatabase: realmDatabase)
                        
        realmResourcesCache = RealmResourcesCache(realmDatabase: realmDatabase)
        
        resourcesDownloader = ResourcesDownloader(languagesApi: languagesApi, resourcesApi: resourcesApi)
        
        resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        
        languagesCache = RealmLanguagesCache(realmDatabase: realmDatabase)
        
        translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesFileCache)
                
        translationDownloader = TranslationDownloader(realmDatabase: realmDatabase, resourcesCache: resourcesCache, translationsApi: translationsApi, translationsFileCache: translationsFileCache)
        
        attachmentsFileCache = AttachmentsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesFileCache)
        
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
                
        resourcesCleanUp = ResourcesCleanUp(
            realmDatabase: realmDatabase,
            translationsFileCache: translationsFileCache,
            resourcesSHA256FileCache: resourcesFileCache,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache
        )
        
        initialDeviceResourcesLoader = InitialDeviceResourcesLoader(
            realmDatabase: realmDatabase,
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
        
        // TODO: Remove LanguagesRepository(cache: languagesCache) allocation here and use getLanguagesRepository().  This will be possible when no longer storing references in AppDiContainer. ~Levi
        languageSettingsService = LanguageSettingsService(
            languagesRepository: LanguagesRepository(cache: languagesCache),
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
                
        appsFlyer = AppsFlyer(config: config, deepLinkingService: appDeepLinkingService)
        
        firebaseInAppMessaging = FirebaseInAppMessaging()
                
        let analyticsLoggingEnabled: Bool = config.build == .analyticsLogging
        analytics = AnalyticsContainer(
            appsFlyerAnalytics: AppsFlyerAnalytics(appsFlyer: appsFlyer, loggingEnabled: analyticsLoggingEnabled),
            firebaseAnalytics: FirebaseAnalytics(config: config, userAuthentication: userAuthentication, languageSettingsService: languageSettingsService, loggingEnabled: analyticsLoggingEnabled),
            snowplowAnalytics: SnowplowAnalytics(config: config, userAuthentication: userAuthentication, loggingEnabled: analyticsLoggingEnabled)
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
    
    static func getNewDeepLinkingService(loggingEnabled: Bool) -> DeepLinkingServiceType {
        
        let manifest = GodToolsDeepLinkingManifest()
        
        return DeepLinkingService(manifest: manifest)
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
    
    func getDeepLinkingService() -> DeepLinkingServiceType {
        return AppDiContainer.getNewDeepLinkingService(loggingEnabled: false)
    }
    
    func getDisableOptInOnboardingBannerUseCase() -> DisableOptInOnboardingBannerUseCase {
        return DisableOptInOnboardingBannerUseCase(optInOnboardingBannerEnabledRepository: getOptInOnboardingBannerEnabledRepository())
    }
    
    func getExitLinkAnalytics() -> ExitLinkAnalytics {
        return ExitLinkAnalytics(firebaseAnalytics: analytics.firebaseAnalytics)
    }
    
    func getFirebaseConfiguration() -> FirebaseConfiguration {
        return FirebaseConfiguration(config: config)
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getFontService() -> FontService {
        return FontService(languageSettings: languageSettingsService)
    }
    
    func getGoogleAdwordsAnalytics() -> GoogleAdwordsAnalytics {
        return GoogleAdwordsAnalytics(config: config)
    }
    
    func getLanguageAvailabilityStringUseCase() -> GetLanguageAvailabilityStringUseCase {
        return GetLanguageAvailabilityStringUseCase(
            localizationServices: localizationServices,
            getTranslatedLanguageUseCase: getTranslatedLanguageUseCase()
        )
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        return LanguagesRepository(cache: languagesCache)
    }
    
    func getLearnToShareToolItemsProvider() -> LearnToShareToolItemsProviderType {
        return InMemoryLearnToShareToolItems(localization: localizationServices)
    }
    
    func getLessonsEvaluationRepository() -> LessonEvaluationRepository {
        return LessonEvaluationRepository(
            cache: LessonEvaluationRealmCache(realmDatabase: realmDatabase)
        )
    }
    
    func getLessonFeedbackAnalytics() -> LessonFeedbackAnalytics {
        return LessonFeedbackAnalytics(
            firebaseAnalytics: analytics.firebaseAnalytics
        )
    }
    
    func getManifestResourcesCache() -> ManifestResourcesCache {
        return ManifestResourcesCache(resourcesFileCache: resourcesFileCache)
    }
    
    func getMobileContentAnalytics() -> MobileContentAnalytics {
        return MobileContentAnalytics(analytics: analytics)
    }
    
    func getMobileContentEventAnalyticsTracking() -> MobileContentEventAnalyticsTracking {
        return MobileContentEventAnalyticsTracking(firebaseAnalytics: analytics.firebaseAnalytics)
    }
    
    func getMobileContentParser() -> MobileContentParser {
        return MobileContentParser(resourcesFileCache: resourcesFileCache)
    }
    
    func getMobileContentRenderer(type: MobileContentRendererPageViewFactoriesType, navigation: MobileContentRendererNavigation, toolTranslations: ToolTranslations) -> MobileContentRenderer {

        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: type,
            appDiContainer: self
        )
        
        return MobileContentRenderer(
            navigation: navigation,
            toolTranslations: toolTranslations,
            pageViewFactories: pageViewFactories,
            manifestResourcesCache: getManifestResourcesCache()
        )
    }
    
    func getMobileContentRendererNavigation(parentFlow: ToolNavigationFlow, navigationDelegate: MobileContentRendererNavigationDelegate) -> MobileContentRendererNavigation {
        
        return MobileContentRendererNavigation(
            parentFlow: parentFlow,
            delegate: navigationDelegate,
            appDiContainer: self
        )
    }
    
    func getOnboardingQuickLinksEnabledUseCase() -> GetOnboardingQuickLinksEnabledUseCase {
        return GetOnboardingQuickLinksEnabledUseCase(deviceLanguage: deviceLanguage)
    }
    
    func getOnboardingTutorialAvailability() -> OnboardingTutorialAvailabilityType {
        return OnboardingTutorialAvailability(
            getTutorialIsAvailableUseCase: getTutorialIsAvailableUseCase(),
            onboardingTutorialViewedCache: getOnboardingTutorialViewedCache(),
            isNewUserCache: isNewUserService.isNewUserCache
        )
    }
    
    func getOnboardingTutorialCustomViewBuilder(flowDelegate: FlowDelegate) -> CustomViewBuilderType {
        return OnboardingTutorialCustomViewBuilder(flowDelegate: flowDelegate, deviceLanguage: deviceLanguage, localizationServices: localizationServices, tutorialVideoAnalytics: getTutorialVideoAnalytics(), analyticsScreenName: "onboarding")
    }
    
    func getOnboardingTutorialViewedCache() -> OnboardingTutorialViewedCacheType {
        return OnboardingTutorialViewedUserDefaultsCache()
    }
    
    func getOptInOnboardingBannerEnabledRepository() -> OptInOnboardingBannerEnabledRepository {
        return OptInOnboardingBannerEnabledRepository(
            cache: OptInOnboardingBannerEnabledCache()
        )
    }
    
    func getOpInOnboardingBannerEnabledUseCase() -> GetOptInOnboardingBannerEnabledUseCase {
        return GetOptInOnboardingBannerEnabledUseCase(
            getOptInOnboardingTutorialAvailableUseCase: getOptInOnboardingTutorialAvailableUseCase(),
            optInOnboardingBannerEnabledRepository: getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getOptInOnboardingTutorialAvailableUseCase() -> GetOptInOnboardingTutorialAvailableUseCase {
        return GetOptInOnboardingTutorialAvailableUseCase(deviceLanguage: deviceLanguage)
    }
    
    func getResourceBannerImageRepository() -> ResourceBannerImageRepository {
        return ResourceBannerImageRepository(
            attachmentsFileCache: attachmentsFileCache,
            bundleBannerImages: BundleResourceBannerImages()
        )
    }
    
    func getSetupParallelLanguageAvailability() -> SetupParallelLanguageAvailabilityType {
        return SetupParallelLanguageAvailability(
            setupParallelLanguageViewedCache: getSetupParallelLanguageViewedCache(),
            isNewUserCache: isNewUserService.isNewUserCache
        )
    }
    
    func getSetupParallelLanguageViewedCache() -> SetupParallelLanguageViewedCacheType {
        return SetupParallelLanguageViewedUserDefaultsCache()
    }
    
    func getShareableImageUseCase() -> GetShareableImageUseCase {
        return GetShareableImageUseCase()
    }
    
    func getShareToolScreenTutorialNumberOfViewsCache() -> ShareToolScreenTutorialNumberOfViewsCache {
        return ShareToolScreenTutorialNumberOfViewsCache(sharedUserDefaultsCache: sharedUserDefaultsCache)
    }
    
    func getToolLanguagesUseCase() -> GetToolLanguagesUseCase {
        return GetToolLanguagesUseCase(
            languagesRepository: getLanguagesRepository(),
            localizationServices: localizationServices
        )
    }
    
    func getToolOpenedAnalytics() -> ToolOpenedAnalytics {
        return ToolOpenedAnalytics(appsFlyerAnalytics: analytics.appsFlyerAnalytics)
    }
    
    func getToolTrainingTipsOnboardingViews() -> ToolTrainingTipsOnboardingViewsService {
        return ToolTrainingTipsOnboardingViewsService(
            cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache(userDefaultsCache: sharedUserDefaultsCache)
        )
    }
    
    func getToolTranslationsUseCase() -> GetToolTranslationsUseCase {
        return GetToolTranslationsUseCase(
            initialDataDownloader: initialDataDownloader,
            translationDownloader: translationDownloader,
            resourcesCache: initialDataDownloader.resourcesCache,
            languagesRepository: getLanguagesRepository(),
            translationsFileCache: translationsFileCache,
            mobileContentParser: getMobileContentParser(),
            languageSettingsService: languageSettingsService
        )
    }
    
    func getToolVersionsUseCase() -> GetToolVersionsUseCase {
        return GetToolVersionsUseCase(
            resourcesCache: initialDataDownloader.resourcesCache,
            localizationServices: localizationServices,
            languageSettingsService: languageSettingsService,
            getToolLanguagesUseCase: getToolLanguagesUseCase(),
            getTranslatedLanguageUseCase: getTranslatedLanguageUseCase()
        )
    }
    
    func getTractRemoteSharePublisher() -> TractRemoteSharePublisher {
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteSharePublisher(
            config: config,
            webSocket: webSocket,
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    func  getTractRemoteShareSubscriber() -> TractRemoteShareSubscriber {
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteShareSubscriber(
            config: config,
            webSocket: webSocket,
            webSocketChannelSubscriber: ActionCableChannelSubscriber(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    func getTractRemoteShareURLBuilder() -> TractRemoteShareURLBuilder {
        return TractRemoteShareURLBuilder()
    }
    
    func getTranslatedLanguageUseCase() -> GetTranslatedLanguageUseCase {
        return GetTranslatedLanguageUseCase(
            languagesRepository: getLanguagesRepository(),
            localizationServices: localizationServices
        )
    }
    
    func getTranslationsRepository() -> TranslationsRepository {
        return TranslationsRepository(
            api: translationsApi,
            cache: RealmTranslationsCache(realmDatabase: realmDatabase),
            resourcesFileCache: resourcesFileCache
        )
    }
    
    func getTutorialIsAvailableUseCase() -> GetTutorialIsAvailableUseCase {
        return GetTutorialIsAvailableUseCase(deviceLanguage: deviceLanguage)
    }
    
    func getTutorialVideoAnalytics() -> TutorialVideoAnalytics {
        return TutorialVideoAnalytics(
            trackActionAnalytics: analytics.trackActionAnalytics
        )
    }
    
    func getViewedTrainingTipsService() -> ViewedTrainingTipsService {
        return ViewedTrainingTipsService(
            cache: ViewedTrainingTipsUserDefaultsCache(sharedUserDefaults: sharedUserDefaultsCache)
        )
    }
}
