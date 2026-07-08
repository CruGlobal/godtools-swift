//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppDiContainer {
    
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
        let accountDataLayer = AccountDataLayerDependencies(coreDataLayer: dataLayer)
        let accountDomainLayer = AccountDomainLayerDependencies(core: core, dataLayer: accountDataLayer)

        let appLanguageDataLayer = AppLanguageDataLayerDependencies(coreDataLayer: dataLayer)
        let appLanguageDomainLayer = AppLanguageDomainLayerDependencies(core: core, dataLayer: appLanguageDataLayer)

        let articlesDataLayer = ArticlesDataLayerDependencies(coreDataLayer: dataLayer)
        let articlesDomainLayer = ArticlesDomainLayerDependencies(core: core, dataLayer: articlesDataLayer)

        let dashboardDataLayer = DashboardDataLayerDependencies(coreDataLayer: dataLayer)
        let dashboardDomainLayer = DashboardDomainLayerDependencies(core: core, dataLayer: dashboardDataLayer)

        let deferredDeepLinkDataLayer = DeferredDeepLinkDataLayerDependencies(coreDataLayer: dataLayer)
        let deferredDeepLinkDomainLayer = DeferredDeepLinkDomainLayerDependencies(core: core, dataLayer: deferredDeepLinkDataLayer)

        let downloadToolProgressDataLayer = DownloadToolProgressDataLayerDependencies(coreDataLayer: dataLayer)
        let downloadToolProgressDomainLayer = DownloadToolProgressDomainLayerDependencies(core: core, dataLayer: downloadToolProgressDataLayer)

        let favoritesDataLayer = FavoritesDataLayerDependencies(coreDataLayer: dataLayer)
        let favoritesDomainLayer = FavoritesDomainLayerDependencies(core: core, dataLayer: favoritesDataLayer)

        let featuredLessonsDataLayer = FeaturedLessonsDataLayerDependencies(coreDataLayer: dataLayer)
        let featuredLessonsDomainLayer = FeaturedLessonsDomainLayerDependencies(core: core, dataLayer: featuredLessonsDataLayer)

        let globalActivityDataLayer = GlobalActivityDataLayerDependencies(coreDataLayer: dataLayer)
        let globalActivityDomainLayer = GlobalActivityDomainLayerDependencies(core: core, dataLayer: globalActivityDataLayer)

        let learnToShareToolDataLayer = LearnToShareToolDataLayerDependencies(coreDataLayer: dataLayer)
        let learnToShareToolDomainLayer = LearnToShareToolDomainLayerDependencies(core: core, dataLayer: learnToShareToolDataLayer)

        let lessonEvaluationDataLayer = LessonEvaluationDataLayerDependencies(coreDataLayer: dataLayer)
        let lessonEvaluationDomainLayer = LessonEvaluationDomainLayerDependencies(core: core, dataLayer: lessonEvaluationDataLayer)

        let lessonFilterDataLayer = LessonFilterDataLayerDependencies(coreDataLayer: dataLayer)
        let lessonFilterDomainLayer = LessonFilterDomainLayerDependencies(core: core, dataLayer: lessonFilterDataLayer)
        
        let onboardingDataLayer = OnboardingDataLayerDependencies(coreDataLayer: dataLayer)
        let onboardingDomainLayer = OnboardingDomainLayerDependencies(core: core, dataLayer: onboardingDataLayer)
        
        let personalizedToolsDataLayer = PersonalizedToolsDataLayerDependencies(coreDataLayer: dataLayer)
        
        let tutorialDataLayer = TutorialDataLayerDependencies(coreDataLayer: dataLayer)
        let tutorialDomainLayer = TutorialDomainLayerDependencies(core: core, dataLayer: tutorialDataLayer)
        
        let feature = AppFeatureDiContainer(
            account: AccountDiContainer(dataLayer: accountDataLayer, domainLayer: accountDomainLayer),
            appLanguage: AppLanguageDiContainer(dataLayer: appLanguageDataLayer, domainLayer: appLanguageDomainLayer),
            articles: ArticlesDiContainer(dataLayer: articlesDataLayer, domainLayer: articlesDomainLayer),
            dashboard: DashboardDiContainer(dataLayer: dashboardDataLayer, domainLayer: dashboardDomainLayer),
            deferredDeepLink: DeferredDeepLinkDiContainer(dataLayer: deferredDeepLinkDataLayer, domainLayer: deferredDeepLinkDomainLayer),
            downloadToolProgress: DownloadToolProgressDiContainer(dataLayer: downloadToolProgressDataLayer, domainLayer: downloadToolProgressDomainLayer),
            favorites: FavoritesDiContainer(dataLayer: favoritesDataLayer, domainLayer: favoritesDomainLayer),
            featuredLessons: FeaturedLessonsDiContainer(dataLayer: featuredLessonsDataLayer, domainLayer: featuredLessonsDomainLayer),
            globalActivity: GlobalActivityDiContainer(dataLayer: globalActivityDataLayer, domainLayer: globalActivityDomainLayer),
            learnToShareTool: LearnToShareToolDiContainer(dataLayer: learnToShareToolDataLayer, domainLayer: learnToShareToolDomainLayer),
            lessonEvaluation: LessonEvaluationDiContainer(dataLayer: lessonEvaluationDataLayer, domainLayer: lessonEvaluationDomainLayer),
            lessonFilter: LessonFilterDiContainer(dataLayer: lessonFilterDataLayer, domainLayer: lessonFilterDomainLayer),
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
    
    func getUrlOpener() -> UrlOpenerInterface {
        return OpenUrlWithSwiftUI() // TODO: GT-2466 Return OpenUrlWithUIKit() once supporting FBSDK 17.3+ ~Levi
    }
    
    @MainActor func getMobileContentRenderer(
        type: MobileContentRendererPageViewFactoriesType,
        navigation: MobileContentRendererNavigation,
        appLanguage: AppLanguageDomainModel,
        toolTranslations: ToolTranslationsDomainModel
    ) -> MobileContentRenderer {

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
    
    @MainActor func getMobileContentRendererNavigation(appLanguage: AppLanguageDomainModel) -> MobileContentRendererNavigation {
        
        return MobileContentRendererNavigation(
            appDiContainer: self,
            appLanguage: appLanguage
        )
    }
    
    private func getMobileContentRendererUserAnalytics() -> MobileContentRendererUserAnalytics {
        return MobileContentRendererUserAnalytics(
            incrementUserCounterUseCase: feature.userActivity.domainLayer.getIncrementUserCounterUseCase()
        )
    }
}
