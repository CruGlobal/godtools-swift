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
    private let resourcesCache: ResourcesCache
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()

    let userAuthentication: UserAuthenticationType
    let favoritedResourcesCache: FavoritedResourcesCache
    let downloadedLanguagesCache: DownloadedLanguagesCache
    let initialDataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let languageDirectionService: LanguageDirectionService
    let isNewUserService: IsNewUserService
    let analytics: AnalyticsContainer
    let localizationServices: LocalizationServices = LocalizationServices()
    let deviceLanguage: DeviceLanguage = DeviceLanguage()
    let globalActivityServices: GlobalActivityServices
    let followUpsService: FollowUpsService
    let viewsService: ViewsService
    let favoritingToolMessageCache: FavoritingToolMessageCache
    let emailSignUpService: EmailSignUpService
    let appsFlyer: AppsFlyerType
    let firebaseInAppMessaging: FirebaseInAppMessagingType
    
    let dataLayer: AppDataLayerDependencies
    let domainLayer: AppDomainLayerDependencies
        
    required init(appDeepLinkingService: DeepLinkingServiceType) {
                        
        dataLayer = AppDataLayerDependencies()
        domainLayer = AppDomainLayerDependencies(dataLayer: dataLayer)
        
        let config: AppConfig = dataLayer.getAppConfig()
        
        let oktaAuthentication: CruOktaAuthentication = OktaAuthenticationConfiguration().configureAndCreateNewOktaAuthentication(config: config)
        userAuthentication = OktaUserAuthentication(oktaAuthentication: oktaAuthentication)
                                        
        resourcesFileCache = ResourcesSHA256FileCache(realmDatabase: realmDatabase)
                                        
        resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
                                                           
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
        
        favoritedResourcesCache = FavoritedResourcesCache(realmDatabase: realmDatabase)
              
        downloadedLanguagesCache = DownloadedLanguagesCache(realmDatabase: realmDatabase)
                                
        initialDataDownloader = InitialDataDownloader(
            resourcesRepository: dataLayer.getResourcesRepository(),
            resourcesCache: resourcesCache
        )
        
        languageSettingsService = LanguageSettingsService(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getSettingsPrimaryLanguageUseCase: domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: domainLayer.getSettingsParallelLanguageUseCase()
        )
        
        languageDirectionService = LanguageDirectionService(languageSettings: languageSettingsService)
                
        isNewUserService = IsNewUserService(
            isNewUserCache: IsNewUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache),
            determineNewUser: DetermineNewUserIfPrimaryLanguageSet(languageSettingsService: languageSettingsService)
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
        return FirebaseConfiguration(config: dataLayer.getAppConfig())
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getFontService() -> FontService {
        return FontService(languageSettings: languageSettingsService)
    }
    
    func getGoogleAdwordsAnalytics() -> GoogleAdwordsAnalytics {
        return GoogleAdwordsAnalytics(config: dataLayer.getAppConfig())
    }
    
    func getLanguageAvailabilityStringUseCase() -> GetLanguageAvailabilityStringUseCase {
        return GetLanguageAvailabilityStringUseCase(
            localizationServices: localizationServices,
            getTranslatedLanguageUseCase: getTranslatedLanguageUseCase()
        )
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
    
    func getMobileContentRenderer(type: MobileContentRendererPageViewFactoriesType, navigation: MobileContentRendererNavigation, toolTranslations: ToolTranslationsDomainModel) -> MobileContentRenderer {

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
    
    func getOnboardingTutorialAvailability() -> OnboardingTutorialAvailabilityType {
        return OnboardingTutorialAvailability(
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
    
    func getToolOpenedAnalytics() -> ToolOpenedAnalytics {
        return ToolOpenedAnalytics(appsFlyerAnalytics: analytics.appsFlyerAnalytics)
    }
    
    func getToolTrainingTipsOnboardingViews() -> ToolTrainingTipsOnboardingViewsService {
        return ToolTrainingTipsOnboardingViewsService(
            cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache(userDefaultsCache: sharedUserDefaultsCache)
        )
    }
    
    func getTractRemoteSharePublisher() -> TractRemoteSharePublisher {
        let config: AppConfig = dataLayer.getAppConfig()
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteSharePublisher(
            config: config,
            webSocket: webSocket,
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    func  getTractRemoteShareSubscriber() -> TractRemoteShareSubscriber {
        let config: AppConfig = dataLayer.getAppConfig()
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
            languagesRepository: dataLayer.getLanguagesRepository(),
            localizationServices: localizationServices
        )
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
