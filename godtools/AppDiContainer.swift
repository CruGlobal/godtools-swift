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
    
    let realmDatabase: RealmDatabase
    let isNewUserCache: IsNewUserCacheType
    let isNewUserService: IsNewUserService
    let config: ConfigType
    let loginClient: TheKeyOAuthClient
    let adobeAnalytics: AdobeAnalyticsType
    let appsFlyer: AppsFlyerType
    let firebaseAnalytics: FirebaseAnalyticsType
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let analytics: GodToolsAnaltyics
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
        
        adobeAnalytics = AdobeAnalytics(config: config, keyAuthClient: loginClient, loggingEnabled: false)
        
        appsFlyer = AppsFlyer(config: config, loggingEnabled: false)
            
        firebaseAnalytics = FirebaseAnalytics()
        
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                
        analytics = GodToolsAnaltyics(config: config, adobeAnalytics: adobeAnalytics, appsFlyer: appsFlyer, firebaseAnalytics: firebaseAnalytics)
        
        languagesManager = LanguagesManager()
    }
    
    var firebaseConfiguration: FirebaseConfiguration {
        return FirebaseConfiguration(config: config)
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
    
    var articleManager: ArticleManager {
        return ArticleManager()
    }
}
