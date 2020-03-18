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
        
    let config: ConfigType
    let appsFlyer: AppsFlyerType
    let loginClient: TheKeyOAuthClient
    let deviceLanguage: DeviceLanguageType
    let toolsLanguagePreferencesCache: ToolsLanguagePreferenceCacheType
    let tutorialSupportedLanguages: TutorialSupportedLanguagesType
    let tutorialAvailability: TutorialAvailabilityType
    let onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType
    let onboardingTutorialAvailability: OnboardingTutorialAvailabilityType
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let analytics: GodToolsAnaltyics
    let globalActivityServices: GlobalActivityServicesType
    
    required init() {
        
        config = AppConfig()
        
        appsFlyer = AppsFlyer(config: config, loggingEnabled: config.isDebug)
        
        loginClient = TheKeyOAuthClient.shared
        
        deviceLanguage = DeviceLanguage()
        
        toolsLanguagePreferencesCache = ToolsLanguagePreferenceUserDefaultsCache()
        
        tutorialSupportedLanguages = TutorialSupportedLanguages()
        
        tutorialAvailability = TutorialAvailability(tutorialSupportedLanguages: tutorialSupportedLanguages)
        
        onboardingTutorialViewedCache = OnboardingTutorialViewedUserDefaultsCache()
        
        onboardingTutorialAvailability = OnboardingTutorialAvailability(
            tutorialAvailability: tutorialAvailability,
            onboardingTutorialViewedCache: onboardingTutorialViewedCache
        )
        
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                
        analytics = GodToolsAnaltyics(config: config, appsFlyer: appsFlyer)
        
        globalActivityServices = GlobalActivityServices(
            globalActivityApi: GlobalActivityAnalyticsApi(config: config),
            globalActivityCache: GlobalActivityAnalyticsUserDefaultsCache()
        )
    }
}
