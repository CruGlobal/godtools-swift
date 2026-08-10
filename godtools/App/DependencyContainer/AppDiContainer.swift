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
    
    init(appBuild: AppBuildInterface, appConfig: AppConfigInterface) {
                
        // core
        let dataLayer = AppDataLayerDependencies(
            appBuild: appBuild,
            appConfig: appConfig
        )
        
        let domainLayer = AppDomainLayerDependencies(
            dataLayer: dataLayer
        )
        
        let core = AppCoreDiContainer(
            dataLayer: dataLayer,
            domainLayer: domainLayer
        )
        
        // feature - share
        let onboardingDataLayer = OnboardingDataLayerDependencies(coreDataLayer: dataLayer)
        let onboardingDomainLayer = OnboardingDomainLayerDependencies(core: core, dataLayer: onboardingDataLayer)
        
        let personalizedToolsDataLayer = PersonalizedToolsDataLayerDependencies(coreDataLayer: dataLayer)
        
        let tutorialDataLayer = TutorialDataLayerDependencies(coreDataLayer: dataLayer)
        let tutorialDomainLayer = TutorialDomainLayerDependencies(core: core, dataLayer: tutorialDataLayer)
        
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
        
        let lessonsDataLayer = LessonsDataLayerDependencies(coreDataLayer: core.dataLayer)
        let lessonsDomainLayer = LessonsDomainLayerDependencies(core: core, dataLayer: lessonsDataLayer, personalizedToolsDataLayer: personalizedToolsDataLayer)

        let userLessonProgressDataLayer = UserLessonProgressDataLayerDependencies(coreDataLayer: dataLayer)
        let userLessonProgressDomainLayer = UserLessonProgressDomainLayerDependencies(core: core, dataLayer: userLessonProgressDataLayer)

        let lessonSwipeTutorialDataLayer = LessonSwipeTutorialDataLayerDependencies(coreDataLayer: dataLayer)
        let lessonSwipeTutorialDomainLayer = LessonSwipeTutorialDomainLayerDependencies(core: core, dataLayer: lessonSwipeTutorialDataLayer)

        let menuDataLayer = MenuDataLayerDependencies(coreDataLayer: dataLayer)
        let menuDomainLayer = MenuDomainLayerDependencies(core: core, dataLayer: menuDataLayer)

        let optInNotificationDataLayer = OptInNotificationDataLayerDependencies(coreDataLayer: core.dataLayer)
        let optInNotificationDomainLayer = OptInNotificationDomainLayerDependencies(core: core, dataLayer: optInNotificationDataLayer, getOnboardingTutorialIsAvailable: onboardingDomainLayer.getOnboardingTutorialIsAvailable())

        let persistToolLanguageSettingsForFavoritedToolDataLayer = PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies(coreDataLayer: dataLayer)
        let persistToolLanguageSettingsForFavoritedToolDomainLayer = PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies(core: core, dataLayer: persistToolLanguageSettingsForFavoritedToolDataLayer)
        
        let personalizedToolsDomainLayer = PersonalizedToolsDomainLayerDependencies(core: core, dataLayer: personalizedToolsDataLayer)

        let shareablesDataLayer = ShareablesDataLayerDependencies(coreDataLayer: dataLayer)
        let shareablesDomainLayer = ShareablesDomainLayerDependencies(core: core, dataLayer: shareablesDataLayer)

        let shareGodToolsDataLayer = ShareGodToolsDataLayerDependencies(coreDataLayer: dataLayer)
        let shareGodToolsDomainLayer = ShareGodToolsDomainLayerDependencies(core: core, dataLayer: shareGodToolsDataLayer)

        let shareToolDataLayer = ShareToolDataLayerDependencies(coreDataLayer: dataLayer)
        let shareToolDomainLayer = ShareToolDomainLayerDependencies(core: core, dataLayer: shareToolDataLayer)

        let spotlightToolsDataLayer = SpotlightToolsDataLayerDependencies(coreDataLayer: dataLayer)
        let spotlightToolsDomainLayer = SpotlightToolsDomainLayerDependencies(core: core, dataLayer: spotlightToolsDataLayer)

        let toolDetailsDataLayer = ToolDetailsDataLayerDependencies(coreDataLayer: dataLayer)
        let toolDetailsDomainLayer = ToolDetailsDomainLayerDependencies(core: core, dataLayer: toolDetailsDataLayer)

        let toolsDataLayer = ToolsDataLayerDependencies(coreDataLayer: core.dataLayer)
        let toolsDomainLayer = ToolsDomainLayerDependencies(core: core, dataLayer: toolsDataLayer, personalizedToolsDataLayer: personalizedToolsDataLayer, tutorialDomainLayer: tutorialDomainLayer)

        let toolScreenShareDataLayer = ToolScreenShareDataLayerDependencies(coreDataLayer: dataLayer)
        let toolScreenShareDomainLayer = ToolScreenShareDomainLayerDependencies(core: core, dataLayer: toolScreenShareDataLayer)

        let toolScreenShareQRCodeDataLayer = ToolScreenShareQRCodeDataLayerDependencies(coreDataLayer: dataLayer)
        let toolScreenShareQRCodeDomainLayer = ToolScreenShareQRCodeDomainLayerDependencies(core: core, dataLayer: toolScreenShareQRCodeDataLayer)

        let toolSettingsDataLayer = ToolSettingsDataLayerDependencies(coreDataLayer: dataLayer)
        let toolSettingsDomainLayer = ToolSettingsDomainLayerDependencies(core: core, dataLayer: toolSettingsDataLayer)

        let toolsFilterDataLayer = ToolsFilterDataLayerDependencies(coreDataLayer: dataLayer)
        let toolsFilterDomainLayer = ToolsFilterDomainLayerDependencies(core: core, dataLayer: toolsFilterDataLayer)

        let toolShortcutLinksDataLayer = ToolShortcutLinksDataLayerDependencies(coreDataLayer: dataLayer)
        let toolShortcutLinksDomainLayer = ToolShortcutLinksDomainLayerDependencies(core: core, dataLayer: toolShortcutLinksDataLayer)

        let userActivityDataLayer = UserActivityDataLayerDependencies(coreDataLayer: dataLayer)
        let userActivityDomainLayer = UserActivityDomainLayerDependencies(core: core, dataLayer: userActivityDataLayer)

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
            lessons: LessonsDiContainer(dataLayer: lessonsDataLayer, domainLayer: lessonsDomainLayer),
            lessonProgress: UserLessonProgressDiContainer(dataLayer: userLessonProgressDataLayer, domainLayer: userLessonProgressDomainLayer),
            lessonSwipeTutorial: LessonSwipeTutorialDiContainer(dataLayer: lessonSwipeTutorialDataLayer, domainLayer: lessonSwipeTutorialDomainLayer),
            menu: MenuDiContainer(dataLayer: menuDataLayer, domainLayer: menuDomainLayer),
            onboarding: OnboardingDiContainer(dataLayer: onboardingDataLayer, domainLayer: onboardingDomainLayer),
            optInNotification: OptInNotificationDiContainer(dataLayer: optInNotificationDataLayer, domainLayer: optInNotificationDomainLayer),
            persistToolLanguageSettingsForFavoritedTool: PersistToolLanguageSettingsForFavoritedToolDiContainer(dataLayer: persistToolLanguageSettingsForFavoritedToolDataLayer, domainLayer: persistToolLanguageSettingsForFavoritedToolDomainLayer),
            personalizedTools: PersonalizedToolsDiContainer(dataLayer: personalizedToolsDataLayer, domainLayer: personalizedToolsDomainLayer),
            shareables: ShareablesDiContainer(dataLayer: shareablesDataLayer, domainLayer: shareablesDomainLayer),
            shareGodTools: ShareGodToolsDiContainer(dataLayer: shareGodToolsDataLayer, domainLayer: shareGodToolsDomainLayer),
            shareTool: ShareToolDiContainer(dataLayer: shareToolDataLayer, domainLayer: shareToolDomainLayer),
            spotlightTools: SpotlightToolsDiContainer(dataLayer: spotlightToolsDataLayer, domainLayer: spotlightToolsDomainLayer),
            toolDetails: ToolDetailsDiContainer(dataLayer: toolDetailsDataLayer, domainLayer: toolDetailsDomainLayer),
            tools: ToolsDiContainer(dataLayer: toolsDataLayer, domainLayer: toolsDomainLayer),
            toolScreenShare: ToolScreenShareDiContainer(dataLayer: toolScreenShareDataLayer, domainLayer: toolScreenShareDomainLayer),
            toolScreenShareQRCode: ToolScreenShareQRCodeDiContainer(dataLayer: toolScreenShareQRCodeDataLayer, domainLayer: toolScreenShareQRCodeDomainLayer),
            toolSettings: ToolSettingsDiContainer(dataLayer: toolSettingsDataLayer, domainLayer: toolSettingsDomainLayer),
            toolsFilter: ToolsFilterDiContainer(dataLayer: toolsFilterDataLayer, domainLayer: toolsFilterDomainLayer),
            toolShortcutLinks: ToolShortcutLinksDiContainer(dataLayer: toolShortcutLinksDataLayer, domainLayer: toolShortcutLinksDomainLayer),
            tutorial: TutorialDiContainer(dataLayer: tutorialDataLayer, domainLayer: tutorialDomainLayer),
            userActivity: UserActivityDiContainer(dataLayer: userActivityDataLayer, domainLayer: userActivityDomainLayer)
        )
        
        self.core = core
        self.feature = feature
    }
    
    static func createUITestsDiContainer() -> AppDiContainer {
        return AppDiContainer(appBuild: UITestsBuild(), appConfig: UITestsAppConfig())
    }
    
    func getUrlOpener() -> UrlOpenerInterface {
        return OpenUrlWithSwiftUI() // TODO: GT-2466 Return OpenUrlWithUIKit() once supporting FBSDK 17.3+ ~Levi
    }
    
    func getMobileContentRenderer(
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
    
    func getMobileContentRendererNavigation(appLanguage: AppLanguageDomainModel) -> MobileContentRendererNavigation {
        
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
