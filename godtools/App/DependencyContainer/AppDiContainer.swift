//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppDiContainer {
        
    enum DataLayerType {
        case godtools
        case mock
    }
    
    private let appBuild: AppBuild
    private let realmDatabase: RealmDatabase
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    
    let dataLayer: CoreDataLayerDependenciesInterface
    let domainLayer: AppDomainLayerDependencies
    let feature: AppFeatureDiContainer
    
    init(appBuild: AppBuild, appConfig: AppConfig, realmDatabase: RealmDatabase, firebaseEnabled: Bool, dataLayerType: DataLayerType) {
               
        self.appBuild = appBuild
        self.realmDatabase = realmDatabase
                
        // TODO: Once MockDataLayerDependencies is no longer pointing to AppDataLayerDependencies, we can remove this. ~Levi
        let godtoolsDataLayer = AppDataLayerDependencies(
            appBuild: appBuild,
            appConfig: appConfig,
            realmDatabase: realmDatabase,
            firebaseEnabled: firebaseEnabled
        )
        
        switch dataLayerType {
        case .godtools:
            dataLayer = godtoolsDataLayer
        case .mock:
            dataLayer = MockDataLayerDependencies(coreDataLayer: godtoolsDataLayer)
        }
        
        domainLayer = AppDomainLayerDependencies(dataLayer: dataLayer)
        
        // feature data layer dependencies
        let accountDataLayer: AccountDataLayerDependenciesInterface
        let onboardingDataLayer: OnboardingDataLayerDependenciesInterface
        let spotlightToolsDataLayer: SpotlightToolsDataLayerDependenciesInterface
        
        switch dataLayerType {
        case .godtools:
            accountDataLayer = AccountDataLayerDependencies(coreDataLayer: dataLayer)
            onboardingDataLayer = OnboardingDataLayerDependencies(coreDataLayer: dataLayer)
            spotlightToolsDataLayer = SpotlightToolsDataLayerDependencies(coreDataLayer: dataLayer)
            
        case .mock:
            accountDataLayer = AccountDataLayerDependencies(coreDataLayer: dataLayer) // NOTE: For now won't use mock until interfaces can be created. ~Levi
            onboardingDataLayer = MockOnboardingDataLayerDependencies()
            spotlightToolsDataLayer = MockSpotlightToolsDataLayerDependencies()
        }
                
        // feature domain interface layer dependencies
        let onboardingDomainInterfaceLayer = OnboardingDomainInterfaceDependencies(coreDataLayer: dataLayer, dataLayer: onboardingDataLayer)
        let spotlightToolsDomainInterfaceLayer = SpotlightToolsDomainInterfaceDependencies(coreDataLayer: dataLayer, dataLayer: spotlightToolsDataLayer)
        
        // feature dependency containers
        let accountDiContainer = AccountDiContainer(coreDataLayer: dataLayer, dataLayer: accountDataLayer, domainInterfaceLayer: AccountDomainInterfaceDependencies(coreDataLayer: dataLayer, dataLayer: accountDataLayer))
        let appLanguageDiContainer = AppLanguageFeatureDiContainer(coreDataLayer: dataLayer)
        let dashboardDiContainer = DashboardDiContainer(coreDataLayer: dataLayer)
        let downloadToolProgressDiContainer = DownloadToolProgressFeatureDiContainer(coreDataLayer: dataLayer)
        let favoritesDiContainer = FavoritesDiContainer(coreDataLayer: dataLayer)
        let featuredLessonsDiContainer = FeaturedLessonsDiContainer(coreDataLayer: dataLayer)
        let globalActivityDiContainer = GlobalActivityDiContainer(coreDataLayer: dataLayer)
        let learnToShareToolDiContainer = LearnToShareToolDiContainer(coreDataLayer: dataLayer)
        let lessonEvaluationDiContainer = LessonEvaluationFeatureDiContainer(coreDataLayer: dataLayer)
        let lessonFilterDiContainer = LessonFilterDiContainer(coreDataLayer: dataLayer)
        let lessonsDiContainer = LessonsFeatureDiContainer(coreDataLayer: dataLayer)
        let lessonProgressDiContainer = UserLessonProgressDiContainer(coreDataLayer: dataLayer)
        let lessonSwipeTutorialDiContainer = LessonSwipeTutorialDiContainer(coreDataLayer: dataLayer)
        let menuDiContainer = MenuDiContainer(coreDataLayer: dataLayer)
        let onboardingDiContainer = OnboardingDiContainer(coreDataLayer: dataLayer, dataLayer: onboardingDataLayer, domainInterfaceLayer: onboardingDomainInterfaceLayer)
        let optInNotification = OptInNotificationDiContainer(coreDataLayer: dataLayer, getOnboardingTutorialIsAvailable: onboardingDomainInterfaceLayer.getOnboardingTutorialIsAvailable())
        let persistFavoritedToolLanguageSettingsDiContainer = PersistUserToolLanguageSettingsDiContainer(coreDataLayer: dataLayer)
        let shareablesDiContainer: ShareablesDiContainer = ShareablesDiContainer(coreDataLayer: dataLayer)
        let shareGodToolsDiContainer = ShareGodToolsDiContainer(coreDataLayer: dataLayer)
        let spotlightToolsDiContainer = SpotlightToolsDiContainer(coreDataLayer: dataLayer, dataLayer: spotlightToolsDataLayer, domainInterfaceLayer: spotlightToolsDomainInterfaceLayer)
        let toolDetailsDiContainer = ToolDetailsFeatureDiContainer(coreDataLayer: dataLayer)
        let toolScreenShareDiContainer = ToolScreenShareFeatureDiContainer(coreDataLayer: dataLayer)
        let toolScreenShareQRCodeDiContainer = ToolScreenShareQRCodeFeatureDiContainer(coreDataLayer: dataLayer)
        let toolSettingsDiContainer = ToolSettingsDiContainer(coreDataLayer: dataLayer)
        let toolsFilterDiContainer = ToolsFilterFeatureDiContainer(coreDataLayer: dataLayer)
        let toolShortcutLinks = ToolShortcutLinksDiContainer(coreDataLayer: dataLayer)
        let tutorialDiContainer = TutorialFeatureDiContainer(coreDataLayer: dataLayer)
        let userActivityDiContainer = UserActivityDiContainer(coreDataLayer: dataLayer)
        
        feature = AppFeatureDiContainer(
            account: accountDiContainer,
            appLanguage: appLanguageDiContainer,
            dashboard: dashboardDiContainer,
            downloadToolProgress: downloadToolProgressDiContainer,
            favorites: favoritesDiContainer,
            featuredLessons: featuredLessonsDiContainer,
            globalActivity: globalActivityDiContainer,
            learnToShareTool: learnToShareToolDiContainer,
            lessonEvaluation: lessonEvaluationDiContainer,
            lessonFilter: lessonFilterDiContainer,
            lessons: lessonsDiContainer, 
            lessonProgress: lessonProgressDiContainer,
            lessonSwipeTutorial: lessonSwipeTutorialDiContainer,
            menu: menuDiContainer,
            onboarding: onboardingDiContainer,
            optInNotification: optInNotification,
            persistFavoritedToolLanguageSettings: persistFavoritedToolLanguageSettingsDiContainer,
            shareables: shareablesDiContainer,
            shareGodTools: shareGodToolsDiContainer,
            spotlightTools: spotlightToolsDiContainer,
            toolDetails: toolDetailsDiContainer,
            toolScreenShare: toolScreenShareDiContainer,
            toolScreenShareQRCode: toolScreenShareQRCodeDiContainer,
            toolSettings: toolSettingsDiContainer,
            toolsFilter: toolsFilterDiContainer,
            toolShortcutLinks: toolShortcutLinks,
            tutorial: tutorialDiContainer,
            userActivity: userActivityDiContainer
        )
                                                                
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
    }
    
    func getCardJumpService() -> CardJumpService {
        return CardJumpService(cardJumpCache: CardJumpUserDefaultsCache(userDefaultsCache: sharedUserDefaultsCache))
    }
    
    func getUrlOpener() -> UrlOpenerInterface {
        return OpenUrlWithSwiftUI() // TODO: GT-2466 Return OpenUrlWithUIKit() once supporting FBSDK 17.3+ ~Levi
    }
    
    func getFirebaseConfiguration() -> FirebaseConfiguration {
        return FirebaseConfiguration(config: dataLayer.getAppConfig())
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getMobileContentRenderer(type: MobileContentRendererPageViewFactoriesType, navigation: MobileContentRendererNavigation, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel) -> MobileContentRenderer {

        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: type,
            appDiContainer: self
        )
        
        return MobileContentRenderer(
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations,
            pageViewFactories: pageViewFactories,
            manifestResourcesCache: getMobileContentRendererManifestResourcesCache()
        )
    }
    
    func getMobileContentRendererAnalytics() -> MobileContentRendererAnalytics {
        return MobileContentRendererAnalytics(
            analytics: dataLayer.getAnalytics(),
            userAnalytics: getMobileContentRendererUserAnalytics()
        )
    }
    
    func getMobileContentRendererEventAnalyticsTracking() -> MobileContentRendererEventAnalyticsTracking {
        return MobileContentRendererEventAnalyticsTracking(firebaseAnalytics: dataLayer.getAnalytics().firebaseAnalytics)
    }
    
    func getMobileContentRendererManifestResourcesCache() -> MobileContentRendererManifestResourcesCache {
        return MobileContentRendererManifestResourcesCache(resourcesFileCache: dataLayer.getResourcesFileCache())
    }
    
    func getMobileContentRendererNavigation(parentFlow: ToolNavigationFlow, navigationDelegate: MobileContentRendererNavigationDelegate, appLanguage: AppLanguageDomainModel) -> MobileContentRendererNavigation {
        
        return MobileContentRendererNavigation(
            parentFlow: parentFlow,
            delegate: navigationDelegate,
            appDiContainer: self,
            appLanguage: appLanguage
        )
    }
    
    private func getMobileContentRendererUserAnalytics() -> MobileContentRendererUserAnalytics {
        return MobileContentRendererUserAnalytics(
            incrementUserCounterUseCase: feature.userActivity.domainLayer.getIncrementUserCounterUseCase()
        )
    }
    
    func getToolTrainingTipsOnboardingViews() -> ToolTrainingTipsOnboardingViewsService {
        return ToolTrainingTipsOnboardingViewsService(
            cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache(
                userDefaultsCache: sharedUserDefaultsCache,
                getTranslatedToolName: dataLayer.getTranslatedToolName()
            )
        )
    }
}
