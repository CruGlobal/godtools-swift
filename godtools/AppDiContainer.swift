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
    
    private let legacyRealmDatabase: LegacyRealmDatabase = LegacyRealmDatabase()
    private let realmDatabase: RealmDatabase
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache = ResourcesSHA256FileCache()
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let translationsApi: TranslationsApiType
    private let realmResourcesCache: RealmResourcesCache
    private let resourcesDownloader: ResourcesDownloader
    private let attachmentsFileCache: AttachmentsFileCache
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    
    let config: ConfigType
    let translationsFileCache: TranslationsFileCache
    let translationDownloader: TranslationDownloader
    let favoritedResourcesCache: FavoritedResourcesCache
    let downloadedLanguagesCache: DownloadedLanguagesCache
    let favoritedResourceTranslationDownloader: FavoritedResourceTranslationDownloader
    let initialDataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let languageTranslationsDownloader: LanguageTranslationsDownloader
    let articleAemImportDownloader: ArticleAemImportDownloader
    let isNewUserService: IsNewUserService
    let loginClient: TheKeyOAuthClient
    let analytics: AnalyticsContainer
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let languagesManager: LanguagesManager
    let localizationServices: LocalizationServices = LocalizationServices()
    let deviceLanguage: DeviceLanguageType = DeviceLanguage()
    let fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel
    let fetchTranslationManifestsViewModel: FetchTranslationManifestsViewModel
        
    required init() {
        
        config = AppConfig()
        
        realmDatabase = RealmDatabase()

        languagesApi = LanguagesApi(config: config)
        
        resourcesApi = ResourcesApi(config: config)
        
        translationsApi = TranslationsApi(config: config)
                        
        realmResourcesCache = RealmResourcesCache(realmDatabase: realmDatabase)
        
        resourcesDownloader = ResourcesDownloader(languagesApi: languagesApi, resourcesApi: resourcesApi, realmResourcesCache: realmResourcesCache)
        
        translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
                
        translationDownloader = TranslationDownloader(realmDatabase: realmDatabase, translationsApi: translationsApi, translationsFileCache: translationsFileCache)
        
        attachmentsFileCache = AttachmentsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
        
        attachmentsDownloader = AttachmentsDownloader(attachmentsFileCache: attachmentsFileCache)
           
        favoritedResourcesCache = FavoritedResourcesCache(realmDatabase: realmDatabase)
              
        downloadedLanguagesCache = DownloadedLanguagesCache(realmDatabase: realmDatabase)
                
        favoritedResourceTranslationDownloader = FavoritedResourceTranslationDownloader(
            realmDatabase: realmDatabase,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache,
            translationDownloader: translationDownloader
        )
        
        initialDataDownloader = InitialDataDownloader(
            realmDatabase: realmDatabase,
            resourcesDownloader: resourcesDownloader,
            attachmentsDownloader: attachmentsDownloader,
            languageSettingsCache: languageSettingsCache,
            deviceLanguage: deviceLanguage,
            favoritedResourceTranslationDownloader: favoritedResourceTranslationDownloader
        )
        
        languageSettingsService = LanguageSettingsService(dataDownloader: initialDataDownloader, languageSettingsCache: languageSettingsCache)
        
        languageTranslationsDownloader = LanguageTranslationsDownloader(
            realmDatabase: realmDatabase,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            downloadedLanguagesCache: downloadedLanguagesCache,
            translationDownloader: translationDownloader
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
        
        fetchLanguageTranslationViewModel = FetchLanguageTranslationViewModel(realmDatabase: realmDatabase, deviceLanguage: deviceLanguage)
        
        fetchTranslationManifestsViewModel = FetchTranslationManifestsViewModel(
            realmDatabase: realmDatabase,
            resourcesCache: initialDataDownloader.resourcesCache,
            languageSettingsService: languageSettingsService,
            translationsFileCache: translationsFileCache
        )
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
        return TractManager(translationsFileCache: translationsFileCache, resourcesSHA256FileCache: resourcesSHA256FileCache)
    }
    
    var toolsManager: ToolsManager {
        // TODO: Eventually want to remove ToolsManager and replace by using ToolsTableView and viewModels with services for populating tools lists. ~Levi
        return ToolsManager.shared
    }
    
    var viewsService: ViewsServiceType {
        return ViewsService(config: config, realmDatabase: realmDatabase)
    }
}
