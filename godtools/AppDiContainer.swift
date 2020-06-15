//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift

class AppDiContainer {
    
    private let godToolsAnalytics: GodToolsAnaltyics
    
    let realmDatabase: RealmDatabase
    let config: ConfigType
    let isNewUserService: IsNewUserService
    let resourcesDownloaderAndCache: ResourcesDownloaderAndCache
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    let loginClient: TheKeyOAuthClient
    let analytics: AnalyticsContainer
    let translationsApi: TranslationsApiType
    let resourceLatestTranslationServices: ResourcesLatestTranslationServices
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let languagesManager: LanguagesManager
        
    required init() {
        
        realmDatabase = RealmDatabase()
        
        config = AppConfig()
        
        isNewUserService = IsNewUserService(languageManager: LanguagesManager())
                        
        resourcesDownloaderAndCache = ResourcesDownloaderAndCache(config: config, realmDatabase: realmDatabase)
        
        favoritedResourcesCache = RealmFavoritedResourcesCache(realmDatabase: realmDatabase)
        
        loginClient = TheKeyOAuthClient.shared
                
        analytics = AnalyticsContainer(
            adobeAnalytics: AdobeAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: config.isDebug),
            appsFlyer: AppsFlyer(config: config, loggingEnabled: config.isDebug),
            firebaseAnalytics: FirebaseAnalytics(),
            snowplowAnalytics: SnowplowAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: config.isDebug)
        )
        
        godToolsAnalytics = GodToolsAnaltyics(analytics: analytics)
                
        translationsApi = TranslationsApi(config: config)
          
        resourceLatestTranslationServices = ResourcesLatestTranslationServices(translationsApi: translationsApi)
                        
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                
        languagesManager = LanguagesManager()
    }
    
    var firebaseConfiguration: FirebaseConfiguration {
        return FirebaseConfiguration(config: config)
    }
    
    var googleAdwordsAnalytics: GoogleAdwordsAnalytics {
        return GoogleAdwordsAnalytics(config: config)
    }
    
    var toolOpenedAnalytics: ToolOpenedAnalytics {
        return ToolOpenedAnalytics(appsFlyer: analytics.appsFlyer)
    }
    
    var exitLinkAnalytics: ExitLinkAnalytics {
        return ExitLinkAnalytics(adobeAnalytics: analytics.adobeAnalytics)
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
        return TutorialAvailability(tutorialSupportedLanguages: tutorialSupportedLanguages)
    }
    
    var deviceLanguage: DeviceLanguageType {
        return DeviceLanguage()
    }
    
    var globalActivityServices: GlobalActivityServicesType {
        return GlobalActivityServices(config: config)
    }
    
    var translationZipImporter: TranslationZipImporter {
        return TranslationZipImporter()
    }

    var articlesService: ArticlesService {
        return ArticlesService(
            resourceLatestTranslationServices: resourceLatestTranslationServices,
            realm: realmDatabase.mainThreadRealm
        )
    }
    
    var tractManager: TractManager {
        return TractManager()
    }
    
    var toolsManager: ToolsManager {
        // TODO: Eventually want to remove ToolsManager and replace by using ToolsTableView and viewModels with services for populating tools lists. ~Levi
        return ToolsManager.shared
    }
    
    var viewsService: ViewsServiceType {
        return ViewsService(config: config, realmDatabase: realmDatabase)
    }
}
