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
        
    private let appBuild: AppBuild
    private let realmDatabase: RealmDatabase = RealmDatabase()
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let sharedIgnoringCacheSession: SharedIgnoreCacheSession = SharedIgnoreCacheSession()
    private let resourcesCache: ResourcesCache
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()

    let oktaUserAuthentication: OktaUserAuthentication
    let initialDataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let isNewUserService: IsNewUserService
    let analytics: AnalyticsContainer
    let localizationServices: LocalizationServices = LocalizationServices()
    let viewsService: ViewsService
    let emailSignUpService: EmailSignUpService
    let firebaseInAppMessaging: FirebaseInAppMessagingType
    
    let dataLayer: AppDataLayerDependencies
    let domainLayer: AppDomainLayerDependencies
        
    init(appBuild: AppBuild, appConfig: AppConfig, infoPlist: InfoPlist) {
               
        self.appBuild = appBuild
        
        dataLayer = AppDataLayerDependencies(appConfig: appConfig, infoPlist: infoPlist)
        domainLayer = AppDomainLayerDependencies(dataLayer: dataLayer)
                
        let oktaAuthentication: CruOktaAuthentication = OktaAuthenticationConfiguration().configureAndCreateNewOktaAuthentication(appBuild: appBuild)
        oktaUserAuthentication = OktaUserAuthentication(oktaAuthentication: oktaAuthentication)
                                        
        resourcesFileCache = ResourcesSHA256FileCache(realmDatabase: realmDatabase)
        
        resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
                                                      
        initialDataDownloader = InitialDataDownloader(
            resourcesRepository: dataLayer.getResourcesRepository(),
            resourcesCache: resourcesCache
        )
        
        languageSettingsService = LanguageSettingsService(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getSettingsPrimaryLanguageUseCase: domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: domainLayer.getSettingsParallelLanguageUseCase()
        )
                        
        isNewUserService = IsNewUserService(
            isNewUserCache: IsNewUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache),
            determineNewUser: DetermineNewUserIfPrimaryLanguageSet(languageSettingsService: languageSettingsService)
        )
                        
        firebaseInAppMessaging = FirebaseInAppMessaging()
                
        let analyticsLoggingEnabled: Bool = appBuild.configuration == .analyticsLogging
        analytics = AnalyticsContainer(
            appsFlyerAnalytics: AppsFlyerAnalytics(appsFlyer: dataLayer.getSharedAppsFlyer(), loggingEnabled: analyticsLoggingEnabled),
            firebaseAnalytics: FirebaseAnalytics(appBuild: appBuild, oktaUserAuthentication: oktaUserAuthentication, loggingEnabled: analyticsLoggingEnabled),
            snowplowAnalytics: SnowplowAnalytics(config: appConfig, oktaUserAuthentication: oktaUserAuthentication, loggingEnabled: analyticsLoggingEnabled)
        )
                                                                                             
        viewsService = ViewsService(config: appConfig, realmDatabase: realmDatabase, sharedSession: sharedIgnoringCacheSession)
                
        emailSignUpService = EmailSignUpService(sharedSession: sharedIgnoringCacheSession, realmDatabase: realmDatabase, oktaUserAuthentication: oktaUserAuthentication)
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
        return OnboardingTutorialCustomViewBuilder(
            flowDelegate: flowDelegate,
            getSettingsPrimaryLanguageUseCase: domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: domainLayer.getSettingsParallelLanguageUseCase(),
            localizationServices: localizationServices,
            tutorialVideoAnalytics: getTutorialVideoAnalytics(),
            analyticsScreenName: "onboarding"
        )
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
        return GetOptInOnboardingTutorialAvailableUseCase(getDeviceLanguageUseCase: domainLayer.getDeviceLanguageUseCase())
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
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: appBuild.isDebug),
            loggingEnabled: appBuild.isDebug
        )
    }
    
    func  getTractRemoteShareSubscriber() -> TractRemoteShareSubscriber {
        let config: AppConfig = dataLayer.getAppConfig()
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteShareSubscriber(
            config: config,
            webSocket: webSocket,
            webSocketChannelSubscriber: ActionCableChannelSubscriber(webSocket: webSocket, loggingEnabled: appBuild.isDebug),
            loggingEnabled: appBuild.isDebug
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
