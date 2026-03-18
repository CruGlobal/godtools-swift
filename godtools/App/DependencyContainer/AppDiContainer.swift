//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppDiContainer {
        
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    
    let dataLayer: AppDataLayerDependencies
    let domainLayer: AppDomainLayerDependencies
    let feature: AppFeatureDiContainer
    
    init(appConfig: AppConfigInterface) {
                       
        dataLayer = AppDataLayerDependencies(
            appConfig: appConfig
        )
        
        domainLayer = AppDomainLayerDependencies(dataLayer: dataLayer)
                
        // feature data layer dependencies
        let personalizedToolsDataLayer = PersonalizedToolsDataLayerDependencies(coreDataLayer: dataLayer)
                
        let onboardingDomainLayer = OnboardingDomainLayerDependencies(coreDataLayer: dataLayer, dataLayer: OnboardingDataLayerDependencies(coreDataLayer: dataLayer))
        
        // feature dependency containers
        let accountDiContainer = AccountDiContainer(coreDataLayer: dataLayer)
        let appLanguageDiContainer = AppLanguageFeatureDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let dashboardDiContainer = DashboardDiContainer(coreDataLayer: dataLayer)
        let deferredDeepLinkDiContainer = DeferredDeepLinkDiContainer(coreDataLayer: dataLayer)
        let downloadToolProgressDiContainer = DownloadToolProgressFeatureDiContainer(coreDataLayer: dataLayer)
        let favoritesDiContainer = FavoritesDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let featuredLessonsDiContainer = FeaturedLessonsDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let globalActivityDiContainer = GlobalActivityDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let learnToShareToolDiContainer = LearnToShareToolDiContainer(coreDataLayer: dataLayer)
        let lessonEvaluationDiContainer = LessonEvaluationFeatureDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let lessonFilterDiContainer = LessonFilterDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let lessonsDiContainer = LessonsFeatureDiContainer(coreDataLayer: dataLayer, coreDomainlayer: domainLayer, personalizedToolsDataLayer: personalizedToolsDataLayer)
        let lessonProgressDiContainer = UserLessonProgressDiContainer(coreDataLayer: dataLayer)
        let lessonSwipeTutorialDiContainer = LessonSwipeTutorialDiContainer(coreDataLayer: dataLayer)
        let menuDiContainer = MenuDiContainer(coreDataLayer: dataLayer)
        let onboardingDiContainer = OnboardingDiContainer(coreDataLayer: dataLayer)
        let optInNotification = OptInNotificationDiContainer(coreDataLayer: dataLayer, getOnboardingTutorialIsAvailableUseCase: onboardingDomainLayer.getOnboardingTutorialIsAvailableUseCase())
        let persistToolLanguageSettingsForFavoritedToolDiContainer = PersistToolLanguageSettingsForFavoritedToolDiContainer(coreDataLayer: dataLayer)
        let personalizedToolsDiContainer: PersonalizedToolsDiContainer = PersonalizedToolsDiContainer(coreDataLayer: dataLayer, coreDomainlayer: domainLayer)
        let shareablesDiContainer: ShareablesDiContainer = ShareablesDiContainer(coreDataLayer: dataLayer)
        let shareGodToolsDiContainer = ShareGodToolsDiContainer(coreDataLayer: dataLayer)
        let shareToolDiContainer = ShareToolDiContainer(coreDataLayer: dataLayer)
        let spotlightToolsDiContainer = SpotlightToolsDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let toolDetailsDiContainer = ToolDetailsFeatureDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let toolsDiContainer = ToolsDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let toolScreenShareDiContainer = ToolScreenShareFeatureDiContainer(coreDataLayer: dataLayer)
        let toolScreenShareQRCodeDiContainer = ToolScreenShareQRCodeFeatureDiContainer(coreDataLayer: dataLayer)
        let toolSettingsDiContainer = ToolSettingsDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let toolsFilterDiContainer = ToolsFilterFeatureDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        let toolShortcutLinks = ToolShortcutLinksDiContainer(coreDataLayer: dataLayer)
        let tutorialDiContainer = TutorialFeatureDiContainer(coreDataLayer: dataLayer)
        let userActivityDiContainer = UserActivityDiContainer(coreDataLayer: dataLayer, coreDomainLayer: domainLayer)
        
        feature = AppFeatureDiContainer(
            account: accountDiContainer,
            appLanguage: appLanguageDiContainer,
            dashboard: dashboardDiContainer,
            deferredDeepLink: deferredDeepLinkDiContainer,
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
            persistToolLanguageSettingsForFavoritedTool: persistToolLanguageSettingsForFavoritedToolDiContainer,
            personalizedTools: personalizedToolsDiContainer,
            shareables: shareablesDiContainer,
            shareGodTools: shareGodToolsDiContainer,
            shareTool: shareToolDiContainer,
            spotlightTools: spotlightToolsDiContainer,
            toolDetails: toolDetailsDiContainer,
            tools: toolsDiContainer,
            toolScreenShare: toolScreenShareDiContainer,
            toolScreenShareQRCode: toolScreenShareQRCodeDiContainer,
            toolSettings: toolSettingsDiContainer,
            toolsFilter: toolsFilterDiContainer,
            toolShortcutLinks: toolShortcutLinks,
            tutorial: tutorialDiContainer,
            userActivity: userActivityDiContainer
        )
                                                                
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: dataLayer.getSharedLegacyRealmDatabase())
    }
    
    static func createUITestsDiContainer() -> AppDiContainer {
        return AppDiContainer(appConfig: UITestsAppConfig())
    }
    
    func getCardJumpService() -> CardJumpService {
        return CardJumpService(cardJumpCache: CardJumpUserDefaultsCache(userDefaultsCache: sharedUserDefaultsCache))
    }
    
    func getUrlOpener() -> UrlOpenerInterface {
        return OpenUrlWithSwiftUI() // TODO: GT-2466 Return OpenUrlWithUIKit() once supporting FBSDK 17.3+ ~Levi
    }
    
    @MainActor func getMobileContentRenderer(type: MobileContentRendererPageViewFactoriesType, navigation: MobileContentRendererNavigation, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel) -> MobileContentRenderer {

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
    
    @MainActor func getMobileContentRendererNavigation(parentFlow: ToolNavigationFlow, navigationDelegate: MobileContentRendererNavigationDelegate, appLanguage: AppLanguageDomainModel) -> MobileContentRendererNavigation {
        
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
                getTranslatedToolName: domainLayer.supporting.getTranslatedToolName()
            )
        )
    }
}
