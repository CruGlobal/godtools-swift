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
    
    private let realmDatabase: RealmDatabase
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache = ResourcesSHA256FileCache()
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let translationsApi: TranslationsApiType
    private let resourcesCache: RealmResourcesCache
    private let resourcesDownloader: ResourcesDownloader
    private let attachmentsFileCache: AttachmentsFileCache
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    
    let config: ConfigType
    let translationsFileCache: TranslationsFileCache
    let translationDownloader: TranslationDownloader
    let favoritedResourcesService: FavoritedResourcesService
    let languageSettingsService: LanguageSettingsService
    let initialDataDownloader: InitialDataDownloader
    let articleAemImportDownloader: ArticleAemImportDownloader
    let isNewUserService: IsNewUserService
    let loginClient: TheKeyOAuthClient
    let analytics: AnalyticsContainer
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let languagesManager: LanguagesManager
    let localizationServices: LocalizationServices = LocalizationServices()
    let deviceLanguage: DeviceLanguageType = DeviceLanguage()
    let preferredLanguageTranslation: PreferredLanguageTranslationViewModel
        
    required init() {
        
        config = AppConfig()
        
        realmDatabase = RealmDatabase()

        languagesApi = LanguagesApi(config: config)
        
        resourcesApi = ResourcesApi(config: config)
        
        translationsApi = TranslationsApi(config: config)
                        
        resourcesCache = RealmResourcesCache(realmDatabase: realmDatabase)
        
        resourcesDownloader = ResourcesDownloader(languagesApi: languagesApi, resourcesApi: resourcesApi, resourcesCache: resourcesCache)
        
        translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
                
        translationDownloader = TranslationDownloader(translationsApi: translationsApi, translationsFileCache: translationsFileCache)
        
        attachmentsFileCache = AttachmentsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
        
        attachmentsDownloader = AttachmentsDownloader(attachmentsFileCache: attachmentsFileCache)
                        
        favoritedResourcesService = FavoritedResourcesService(realmDatabase: realmDatabase)
        
        languageSettingsService = LanguageSettingsService(resourcesCache: resourcesCache, languageSettingsCache: languageSettingsCache)
        
        initialDataDownloader = InitialDataDownloader(
            realmDatabase: realmDatabase,
            resourcesDownloader: resourcesDownloader,
            attachmentsDownloader: attachmentsDownloader,
            languageSettingsService: languageSettingsService,
            deviceLanguage: deviceLanguage
        )
        
        articleAemImportDownloader = ArticleAemImportDownloader(realmDatabase: realmDatabase)
                
        isNewUserService = IsNewUserService(languageSettingsCache: languageSettingsCache)
        
        loginClient = TheKeyOAuthClient.shared
                
        analytics = AnalyticsContainer(
            adobeAnalytics: AdobeAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: config.isDebug),
            appsFlyer: AppsFlyer(config: config, loggingEnabled: config.isDebug),
            firebaseAnalytics: FirebaseAnalytics(),
            snowplowAnalytics: SnowplowAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: config.isDebug)
        )
        
        godToolsAnalytics = GodToolsAnaltyics(analytics: analytics)
                                                  
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                
        languagesManager = LanguagesManager()
        
        preferredLanguageTranslation = PreferredLanguageTranslationViewModel(resourcesCache: resourcesCache, languageSettingsCache: languageSettingsCache, deviceLanguage: deviceLanguage)
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
    
    var globalActivityServices: GlobalActivityServicesType {
        return GlobalActivityServices(config: config)
    }
    
    var translationZipImporter: TranslationZipImporter {
        return TranslationZipImporter()
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
