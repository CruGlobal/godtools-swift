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
    
    let isNewUserService: IsNewUserService
    let realmDatabase: RealmDatabase
    let config: ConfigType
    let languagesApi: LanguagesApiType
    let resourcesApi: ResourcesApiType
    let translationsApi: TranslationsApiType
    let resourcesCache: ResourcesCache
    let resourceAttachmentsServices: ResourceAttachmentsServices
    let resourceTranslationsServices: ResourceTranslationsServices
    let resourcesService: ResourcesService
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    let loginClient: TheKeyOAuthClient
    let analytics: AnalyticsContainer
    let resourceLatestTranslationServices: ResourcesLatestTranslationServices
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let languagesManager: LanguagesManager
        
    required init() {
        
        isNewUserService = IsNewUserService(languageSettingsCache: languageSettingsCache)
        
        realmDatabase = RealmDatabase()

        config = AppConfig()
        
        languagesApi = LanguagesApi(config: config)
        
        resourcesApi = ResourcesApi(config: config)
        
        translationsApi = TranslationsApi(config: config)
        
        resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        
        resourceAttachmentsServices = ResourceAttachmentsServices(resourcesCache: resourcesCache)
        
        resourceTranslationsServices = ResourceTranslationsServices(translationsApi: translationsApi, resourcesCache: resourcesCache)
                        
        resourcesService = ResourcesService(languagesApi: languagesApi, resourcesApi: resourcesApi, translationsApi: translationsApi, resourcesCache: resourcesCache, attachmentsServices: resourceAttachmentsServices, translationsServices: resourceTranslationsServices)
        
        favoritedResourcesCache = RealmFavoritedResourcesCache(realmDatabase: realmDatabase)
        
        loginClient = TheKeyOAuthClient.shared
                
        analytics = AnalyticsContainer(
            adobeAnalytics: AdobeAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: config.isDebug),
            appsFlyer: AppsFlyer(config: config, loggingEnabled: config.isDebug),
            firebaseAnalytics: FirebaseAnalytics(),
            snowplowAnalytics: SnowplowAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: config.isDebug)
        )
        
        godToolsAnalytics = GodToolsAnaltyics(analytics: analytics)
                          
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
