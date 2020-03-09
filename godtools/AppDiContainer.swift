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
    let onboardingTutorialServices: OnboardingTutorialServicesType
    let tutorialServices: TutorialServicesType
    let analytics: GodToolsAnaltyics
    let globalActivityServices: GlobalActivityServicesType
    
    required init() {
        
        config = AppConfig()
        appsFlyer = AppsFlyer(config: config, loggingEnabled: config.isDebug)
        loginClient = TheKeyOAuthClient.shared
        onboardingTutorialServices = OnboardingTutorialServices(languagePreferences: DeviceLanguagePreferences())
        tutorialServices = TutorialServices(languagePreferences: DeviceLanguagePreferences())
        analytics = GodToolsAnaltyics(config: config, appsFlyer: appsFlyer)
        globalActivityServices = GlobalActivityServices(
            globalActivityApi: GlobalActivityAnalyticsApi(config: config),
            globalActivityCache: GlobalActivityAnalyticsUserDefaultsCache()
        )
    }
}
