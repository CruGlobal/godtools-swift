//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppDiContainer {
        
    private let appBuild: AppBuild
    private let realmDatabase: RealmDatabase
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    
    let dataLayer: AppDataLayerDependencies
    let domainLayer: AppDomainLayerDependencies
    let feature: AppFeatureDiContainer
        
    init(appBuild: AppBuild, appConfig: AppConfig, infoPlist: InfoPlist, realmDatabase: RealmDatabase) {
               
        self.appBuild = appBuild
        self.realmDatabase = realmDatabase
        
        dataLayer = AppDataLayerDependencies(appBuild: appBuild, appConfig: appConfig, infoPlist: infoPlist, realmDatabase: realmDatabase)
        domainLayer = AppDomainLayerDependencies(dataLayer: dataLayer)
        
        let appLanguageDiContainer = AppLanguageFeatureDiContainer(coreDataLayer: dataLayer)
        let lessonEvaluationDiContainer = LessonEvaluationFeatureDiContainer(coreDataLayer: dataLayer)
        let lessonsDiContainer = LessonsFeatureDiContainer(coreDataLayer: dataLayer, appLanguageFeatureDiContainer: appLanguageDiContainer)
        let featuredLessonsDiContainer = FeaturedLessonsDiContainer(coreDataLayer: dataLayer, appLanguageFeatureDomainLayer: appLanguageDiContainer.domainLayer, lessonsFeatureDomainLayer: lessonsDiContainer.domainLayer)
        let onboardingDiContainer = OnboardingDiContainer(coreDataLayer: dataLayer, appDomainLayer: domainLayer, appLanguageFeatureDomainLayer: appLanguageDiContainer.domainLayer)
        let toolDetailsDiContainer = ToolDetailsFeatureDiContainer(coreDataLayer: dataLayer, appLanguageFeatureDiContainer: appLanguageDiContainer)
        
        feature = AppFeatureDiContainer(
            appLanguage: appLanguageDiContainer,
            featuredLessons: featuredLessonsDiContainer,
            lessonEvaluation: lessonEvaluationDiContainer,
            lessons: lessonsDiContainer,
            onboarding: onboardingDiContainer,
            toolDetails: toolDetailsDiContainer
        )
                                                                
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
    }
    
    func getCardJumpService() -> CardJumpService {
        return CardJumpService(cardJumpCache: CardJumpUserDefaultsCache(sharedUserDefaultsCache: sharedUserDefaultsCache))
    }
    
    func getFirebaseConfiguration() -> FirebaseConfiguration {
        return FirebaseConfiguration(config: dataLayer.getAppConfig())
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getFontService() -> FontService {
        return FontService(getSettingsPrimaryLanguageUseCase: domainLayer.getSettingsPrimaryLanguageUseCase())
    }
    
    func getGoogleAdwordsAnalytics() -> GoogleAdwordsAnalytics {
        return GoogleAdwordsAnalytics(config: dataLayer.getAppConfig())
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
    
    func getMobileContentRendererNavigation(parentFlow: ToolNavigationFlow, navigationDelegate: MobileContentRendererNavigationDelegate) -> MobileContentRendererNavigation {
        
        return MobileContentRendererNavigation(
            parentFlow: parentFlow,
            delegate: navigationDelegate,
            appDiContainer: self
        )
    }
    
    private func getMobileContentRendererUserAnalytics() -> MobileContentRendererUserAnalytics {
        return MobileContentRendererUserAnalytics(
            incrementUserCounterUseCase: domainLayer.getIncrementUserCounterUseCase()
        )
    }
    
    func getShareToolScreenTutorialNumberOfViewsCache() -> ShareToolScreenTutorialNumberOfViewsCache {
        return ShareToolScreenTutorialNumberOfViewsCache(sharedUserDefaultsCache: sharedUserDefaultsCache)
    }
    
    func getToolOpenedAnalytics() -> ToolOpenedAnalytics {
        return ToolOpenedAnalytics(appsFlyerAnalytics: dataLayer.getAnalytics().appsFlyerAnalytics)
    }
    
    func getToolTrainingTipsOnboardingViews() -> ToolTrainingTipsOnboardingViewsService {
        return ToolTrainingTipsOnboardingViewsService(
            cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache(userDefaultsCache: sharedUserDefaultsCache)
        )
    }
}
