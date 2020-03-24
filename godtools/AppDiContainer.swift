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
    let appsFlyer: AppsFlyerType
    let loginClient: TheKeyOAuthClient
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let analytics: GodToolsAnaltyics
    
    required init() {
        
        realmDatabase = RealmDatabase()
        
        isNewUserCache = IsNewUserDefaultsCache()
        
        isNewUserService = IsNewUserService(
            determineNewUser: DetermineNewUserIfPrimaryLanguageSet(languageManager: LanguagesManager()),
            isNewUserCache: isNewUserCache
        )
        
        config = AppConfig()
        
        appsFlyer = AppsFlyer(config: config, loggingEnabled: config.isDebug)
        
        loginClient = TheKeyOAuthClient.shared
                        
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                
        analytics = GodToolsAnaltyics(config: config, appsFlyer: appsFlyer)
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
    
    var toolsLanguagePreferencesCache: ToolsLanguagePreferenceCacheType {
        return ToolsLanguagePreferenceUserDefaultsCache()
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
}
