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
    let isNewUserCache: IsNewUserCacheType
    let isNewUserService: IsNewUserService
    let config: ConfigType
    let loginClient: TheKeyOAuthClient
    let analytics: AnalyticsContainer
    let translationsApi: TranslationsApiType
    let resourceLatestTranslationServices: ResourceLatestTranslationServices
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let languagesManager: LanguagesManager
    
    required init() {
        
        realmDatabase = RealmDatabase()
        
        isNewUserCache = IsNewUserDefaultsCache()
        
        isNewUserService = IsNewUserService(
            determineNewUser: DetermineNewUserIfPrimaryLanguageSet(languageManager: LanguagesManager()),
            isNewUserCache: isNewUserCache
        )
        
        config = AppConfig()
        
        loginClient = TheKeyOAuthClient.shared
        
        let analyticsLoggingEnabled: Bool = config.isDebug
        analytics = AnalyticsContainer(
            adobeAnalytics: AdobeAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: analyticsLoggingEnabled),
            appsFlyer: AppsFlyer(config: config, loggingEnabled: analyticsLoggingEnabled),
            firebaseAnalytics: FirebaseAnalytics(),
            snowplowAnalytics: SnowplowAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: analyticsLoggingEnabled),
            trackActionAnalytics: trackActionAnalytics
        )
        
        godToolsAnalytics = GodToolsAnaltyics(analytics: analytics)
                
        translationsApi = TranslationsApi(config: config)
          
        resourceLatestTranslationServices = ResourceLatestTranslationServices(translationsApi: translationsApi)
                        
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
        return ToolOpenedAnalytics(
            appsFlyer: analytics.appsFlyer,
            snowplowAnalytics: analytics.snowplowAnalytics
        )
    }
    
    var trackActionAnalytics: TrackActionAnalytics {
        return TrackActionAnalytics(
            adobeAnalytics: analytics.adobeAnalytics,
            snowplowAnalytics: analytics.snowplowAnalytics
        )
    }
    
    var exitLinkAnalytics: ExitLinkAnalytics {
        return ExitLinkAnalytics(adobeAnalytics: analytics.adobeAnalytics)
    }
    
    var onboardingTutorialAvailability: OnboardingTutorialAvailabilityType {
        return OnboardingTutorialAvailability(
            tutorialAvailability: tutorialAvailability,
            onboardingTutorialViewedCache: onboardingTutorialViewedCache,
            isNewUserCache: isNewUserCache
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
        return GlobalActivityServices(
            globalActivityApi: GlobalActivityAnalyticsApi(config: config),
            globalActivityCache: GlobalActivityAnalyticsUserDefaultsCache()
        )
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
}
