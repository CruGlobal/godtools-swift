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
    
    private let godToolsAnalytics: GodToolsAnaltyics // TODO: Remove GodToolsAnalytics, replaced by AnalyticsContainer. ~Levi
    
    private let resourcesSHA256FileCache: SHA256FilesCache = SHA256FilesCache(rootDirectory: "resources_files")
    private let realmDatabase: RealmDatabase
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let translationsApi: TranslationsApiType
    private let translationsFileCache: TranslationsFileCache
    private let realmResourcesCache: RealmResourcesCache
    
    let config: ConfigType
    let resourceAttachmentsService: ResourceAttachmentsService
    let resourceTranslationsServices: ResourceTranslationsServices
    let resourcesService: ResourcesService
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let languageSettingsCache: LanguageSettingsCacheType
    let isNewUserService: IsNewUserService
    let loginClient: TheKeyOAuthClient
    let analytics: AnalyticsContainer
    let resourceLatestTranslationServices: ResourcesLatestTranslationServices
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let languagesManager: LanguagesManager
        
    required init() {
        
        config = AppConfig()
        
        realmDatabase = RealmDatabase()

        languagesApi = LanguagesApi(config: config)
        
        resourcesApi = ResourcesApi(config: config)
        
        translationsApi = TranslationsApi(config: config)
                
        translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
        
        realmResourcesCache = RealmResourcesCache(realmDatabase: realmDatabase)
                
        resourceAttachmentsService = ResourceAttachmentsService(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
        
        resourceTranslationsServices = ResourceTranslationsServices(translationsApi: translationsApi)
                        
        resourcesService = ResourcesService(languagesApi: languagesApi, resourcesApi: resourcesApi, translationsApi: translationsApi, realmResourcesCache: realmResourcesCache, attachmentsService: resourceAttachmentsService, translationsServices: resourceTranslationsServices)
        
        favoritedResourcesCache = RealmFavoritedResourcesCache(realmDatabase: realmDatabase)
        
        languageSettingsCache = LanguageSettingsUserDefaultsCache(realmResourcesCache: realmResourcesCache)
        
        isNewUserService = IsNewUserService(languageSettingsCache: languageSettingsCache)
        
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
