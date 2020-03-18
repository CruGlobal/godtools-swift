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
       
    private(set) lazy var tutorialSupportedLanguages: TutorialSupportedLanguagesType = {
        return TutorialSupportedLanguages()
    }()
    private(set) lazy var tutorialAvailability: TutorialAvailabilityType = {
        return TutorialAvailability(tutorialSupportedLanguages: tutorialSupportedLanguages)
    }()
    
    private(set) lazy var onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType = {
        return OnboardingTutorialViewedUserDefaultsCache()
    }()
    
    private(set) lazy var onboardingTutorialAvailability: OnboardingTutorialAvailabilityType = {
        return OnboardingTutorialAvailability(
            tutorialAvailability: tutorialAvailability,
            onboardingTutorialViewedCache: onboardingTutorialViewedCache
        )
    }()
    
    let config: ConfigType
    let appsFlyer: AppsFlyerType
    let loginClient: TheKeyOAuthClient
    let deviceLanguage: DeviceLanguageType
    let toolsLanguagePreferencesCache: ToolsLanguagePreferenceCacheType
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let analytics: GodToolsAnaltyics
    let globalActivityServices: GlobalActivityServicesType
    
    required init() {
        
        config = AppConfig()
        
        appsFlyer = AppsFlyer(config: config, loggingEnabled: config.isDebug)
        
        loginClient = TheKeyOAuthClient.shared
        
        deviceLanguage = DeviceLanguage()
        
        toolsLanguagePreferencesCache = ToolsLanguagePreferenceUserDefaultsCache()
        
        openTutorialCalloutCache = OpenTutorialCalloutUserDefaultsCache()
                
        analytics = GodToolsAnaltyics(config: config, appsFlyer: appsFlyer)
        
        globalActivityServices = GlobalActivityServices(
            globalActivityApi: GlobalActivityAnalyticsApi(config: config),
            globalActivityCache: GlobalActivityAnalyticsUserDefaultsCache()
        )
    }
}
