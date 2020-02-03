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
        
    let loginClient: TheKeyOAuthClient
    let onboardingTutorialServices: OnboardingTutorialServicesType
    let tutorialServices: TutorialServicesType
    
    required init() {
        
        loginClient = TheKeyOAuthClient.shared
        onboardingTutorialServices = OnboardingTutorialServices(languagePreferences: DeviceLanguagePreferences())
        tutorialServices = TutorialServices(languagePreferences: DeviceLanguagePreferences())
    }
}
