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
    
    private let legacyRealmMigration: LegacyRealmMigration
    private let realmDatabase: RealmDatabase
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache = ResourcesSHA256FileCache()
    private let sharedIgnoringCacheSession: SharedIgnoreCacheSession = SharedIgnoreCacheSession()
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let translationsApi: TranslationsApiType
    private let realmResourcesCache: RealmResourcesCache
    private let resourcesDownloader: ResourcesDownloader
    private let resourcesCache: ResourcesCache
    private let languagesCache: LanguagesCache
    private let attachmentsFileCache: AttachmentsFileCache
    private let attachmentsDownloader: AttachmentsDownloader
    private let failedFollowUpsCache: FailedFollowUpsCache
    private let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    private let resourcesCleanUp: ResourcesCleanUp
    private let initialDeviceResourcesLoader: InitialDeviceResourcesLoader
    private let sharedUserDefaultsCache: SharedUserDefaultsCache = SharedUserDefaultsCache()

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
    let localizationServices: LocalizationServices = LocalizationServices()
    let deviceLanguage: DeviceLanguageType = DeviceLanguage()
    let fetchTranslationManifestsViewModel: FetchTranslationManifestsViewModel
    let globalActivityServices: GlobalActivityServicesType
    let followUpsService: FollowUpsService
    let viewsService: ViewsService
    let shortcutItemsService: ShortcutItemsService
    let deepLinkingService: DeepLinkingService
    let deviceAttachmentBanners: DeviceAttachmentBanners = DeviceAttachmentBanners()
    let favoritingToolMessageCache: FavoritingToolMessageCache
        
    required init() {
        
        config = AppConfig()
        
        realmDatabase = RealmDatabase()

        languagesApi = LanguagesApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        resourcesApi = ResourcesApi(config: config, sharedSession: sharedIgnoringCacheSession)
        
        translationsApi = TranslationsApi(config: config, sharedSession: sharedIgnoringCacheSession)
                        
        realmResourcesCache = RealmResourcesCache(realmDatabase: realmDatabase)
        
        resourcesDownloader = ResourcesDownloader(languagesApi: languagesApi, resourcesApi: resourcesApi)
        
        resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        
        languagesCache = LanguagesCache(realmDatabase: realmDatabase)
        
        translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
                
        translationDownloader = TranslationDownloader(realmDatabase: realmDatabase, translationsApi: translationsApi, translationsFileCache: translationsFileCache)
        
        attachmentsFileCache = AttachmentsFileCache(realmDatabase: realmDatabase, sha256FileCache: resourcesSHA256FileCache)
        
        attachmentsDownloader = AttachmentsDownloader(attachmentsFileCache: attachmentsFileCache, sharedSession: sharedIgnoringCacheSession)
           
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
        
        favoritedResourcesCache = FavoritedResourcesCache(realmDatabase: realmDatabase)
              
        downloadedLanguagesCache = DownloadedLanguagesCache(realmDatabase: realmDatabase)
                
        favoritedResourceTranslationDownloader = FavoritedResourceTranslationDownloader(
            realmDatabase: realmDatabase,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache,
            translationDownloader: translationDownloader
        )
        
        legacyRealmMigration = LegacyRealmMigration(
            realmDatabase: realmDatabase,
            languageSettingsCache: languageSettingsCache,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache,
            failedFollowUpsCache: failedFollowUpsCache
        )
        
        resourcesCleanUp = ResourcesCleanUp(
            realmDatabase: realmDatabase,
            translationsFileCache: translationsFileCache,
            resourcesSHA256FileCache: resourcesSHA256FileCache,
            favoritedResourcesCache: favoritedResourcesCache,
            downloadedLanguagesCache: downloadedLanguagesCache
        )
        
        initialDeviceResourcesLoader = InitialDeviceResourcesLoader(
            realmDatabase: realmDatabase,
            legacyRealmMigration: legacyRealmMigration,
            attachmentsFileCache: attachmentsFileCache,
            translationsFileCache: translationsFileCache,
            realmResourcesCache: realmResourcesCache,
            favoritedResourcesCache: favoritedResourcesCache,
            languagesCache: languagesCache,
            deviceLanguage: deviceLanguage,
            languageSettingsCache: languageSettingsCache
        )
        
        initialDataDownloader = InitialDataDownloader(
            realmDatabase: realmDatabase,
            initialDeviceResourcesLoader: initialDeviceResourcesLoader,
            resourcesDownloader: resourcesDownloader,
            realmResourcesCache: realmResourcesCache,
            resourcesCache: resourcesCache,
            languagesCache: languagesCache,
            resourcesCleanUp: resourcesCleanUp,
            attachmentsDownloader: attachmentsDownloader,
            languageSettingsCache: languageSettingsCache,
            favoritedResourceTranslationDownloader: favoritedResourceTranslationDownloader
        )
        
        languageSettingsService = LanguageSettingsService(
            dataDownloader: initialDataDownloader,
            languageSettingsCache: languageSettingsCache
        )
        
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
            adobeAnalytics: AdobeAnalytics(config: config, keyAuthClient: loginClient, languageSettingsService: languageSettingsService, loggingEnabled: false),
            appsFlyer: AppsFlyer(config: config, loggingEnabled: false),
            firebaseAnalytics: FirebaseAnalytics(),
            snowplowAnalytics: SnowplowAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: false)
        )
        
        godToolsAnalytics = GodToolsAnaltyics(analytics: analytics)
                                                  
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                                
        fetchTranslationManifestsViewModel = FetchTranslationManifestsViewModel(
            realmDatabase: realmDatabase,
            resourcesCache: initialDataDownloader.resourcesCache,
            languageSettingsService: languageSettingsService,
            translationsFileCache: translationsFileCache
        )
        
        globalActivityServices = GlobalActivityServices(config: config, sharedSession: sharedIgnoringCacheSession)
        
        followUpsService = FollowUpsService(config: config, sharedSession: sharedIgnoringCacheSession, failedFollowUpsCache: failedFollowUpsCache)
        
        viewsService = ViewsService(config: config, realmDatabase: realmDatabase, sharedSession: sharedIgnoringCacheSession)
        
        shortcutItemsService = ShortcutItemsService(
            realmDatabase: realmDatabase,
            dataDownloader: initialDataDownloader,
            languageSettingsCache: languageSettingsCache,
            favoritedResourcesCache: favoritedResourcesCache
        )
        
        deepLinkingService = DeepLinkingService(dataDownloader: initialDataDownloader)
        
        favoritingToolMessageCache = FavoritingToolMessageCache(userDefaultsCache: sharedUserDefaultsCache)
                
        // TODO: Need to remove this singleton once UIFont extension is properly refactored. ~Levi
        // UIFont extension currently depends on the primary language for picking appropriate UIFont to display.
        LanguagesManager.shared.setup(languageSettingsService: languageSettingsService)
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
    
    var tractRemoteShareSubscriber: TractRemoteShareSubscriber {
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteShareSubscriber(
            config: config,
            webSocket: webSocket,
            webSocketChannelSubscriber: ActionCableChannelSubscriber(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    var tractRemoteSharePublisher: TractRemoteSharePublisher {
        let webSocket: WebSocketType = StarscreamWebSocket()
        return TractRemoteSharePublisher(
            config: config,
            webSocket: webSocket,
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: config.isDebug),
            loggingEnabled: config.isDebug
        )
    }
    
    var tractManager: TractManager {
        return TractManager(translationsFileCache: translationsFileCache, resourcesSHA256FileCache: resourcesSHA256FileCache)
    }
}
