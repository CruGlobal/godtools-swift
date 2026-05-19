//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppDiContainer {
        
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    
    let core: AppCoreDiContainer
    let feature: AppFeatureDiContainer
    
    init(appConfig: AppConfigInterface) {
                
        // core
        let dataLayer = AppDataLayerDependencies(
            appConfig: appConfig
        )
        
        let domainLayer = AppDomainLayerDependencies(
            dataLayer: dataLayer
        )
        
        let core = AppCoreDiContainer(
            dataLayer: dataLayer,
            domainLayer: domainLayer
        )
        
        // feature
        let onboardingDataLayer = OnboardingDataLayerDependencies(coreDataLayer: dataLayer)
        let onboardingDomainLayer = OnboardingDomainLayerDependencies(core: core, dataLayer: onboardingDataLayer)
        
        let personalizedToolsDataLayer = PersonalizedToolsDataLayerDependencies(coreDataLayer: dataLayer)
        
        let tutorialDataLayer = TutorialDataLayerDependencies(coreDataLayer: dataLayer)
        let tutorialDomainLayer = TutorialDomainLayerDependencies(core: core, dataLayer: tutorialDataLayer)
        
        let feature = AppFeatureDiContainer(
            account: AccountDiContainer(core: core),
            appLanguage: AppLanguageDiContainer(core: core),
            articles: ArticlesDiContainer(core: core),
            dashboard: DashboardDiContainer(core: core),
            deferredDeepLink: DeferredDeepLinkDiContainer(core: core),
            downloadToolProgress: DownloadToolProgressDiContainer(core: core),
            favorites: FavoritesDiContainer(core: core),
            featuredLessons: FeaturedLessonsDiContainer(core: core),
            globalActivity: GlobalActivityDiContainer(core: core),
            learnToShareTool: LearnToShareToolDiContainer(core: core),
            lessonEvaluation: LessonEvaluationDiContainer(core: core),
            lessonFilter: LessonFilterDiContainer(core: core),
            lessons: LessonsDiContainer(core: core, personalizedToolsDataLayer: personalizedToolsDataLayer),
            lessonProgress: UserLessonProgressDiContainer(core: core),
            lessonSwipeTutorial: LessonSwipeTutorialDiContainer(core: core),
            menu: MenuDiContainer(core: core),
            onboarding: OnboardingDiContainer(dataLayer: onboardingDataLayer, domainLayer: onboardingDomainLayer),
            optInNotification: OptInNotificationDiContainer(core: core, getOnboardingTutorialIsAvailable: onboardingDomainLayer.getOnboardingTutorialIsAvailable()),
            persistToolLanguageSettingsForFavoritedTool: PersistToolLanguageSettingsForFavoritedToolDiContainer(core: core),
            personalizedTools: PersonalizedToolsDiContainer(core: core, personalizedToolsDataLayer: personalizedToolsDataLayer),
            shareables: ShareablesDiContainer(core: core),
            shareGodTools: ShareGodToolsDiContainer(core: core),
            shareTool: ShareToolDiContainer(core: core),
            spotlightTools: SpotlightToolsDiContainer(core: core),
            toolDetails: ToolDetailsDiContainer(core: core),
            tools: ToolsDiContainer(core: core, personalizedToolsDataLayer: personalizedToolsDataLayer, tutorialDomainLayer: tutorialDomainLayer),
            toolScreenShare: ToolScreenShareDiContainer(core: core),
            toolScreenShareQRCode: ToolScreenShareQRCodeDiContainer(core: core),
            toolSettings: ToolSettingsDiContainer(core: core),
            toolsFilter: ToolsFilterDiContainer(core: core),
            toolShortcutLinks: ToolShortcutLinksDiContainer(core: core),
            tutorial: TutorialDiContainer(dataLayer: tutorialDataLayer, domainLayer: tutorialDomainLayer),
            userActivity: UserActivityDiContainer(core: core)
        )
        
        self.core = core
        self.feature = feature
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
            manifestResourcesCache: core.dataLayer.getMobileContentRendererManifestResourcesCache()
        )
    }
    
    func getMobileContentRendererAnalytics() -> MobileContentRendererAnalytics {
        return MobileContentRendererAnalytics(
            analytics: core.dataLayer.getAnalytics(),
            userAnalytics: getMobileContentRendererUserAnalytics()
        )
    }
    
    func getMobileContentRendererEventAnalyticsTracking() -> MobileContentRendererEventAnalyticsTracking {
        return MobileContentRendererEventAnalyticsTracking(firebaseAnalytics: core.dataLayer.getAnalytics().firebaseAnalytics)
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
                getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName()
            )
        )
    }
}
