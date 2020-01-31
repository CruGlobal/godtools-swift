//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AppDiContainer {
        
    let onboardingTutorialServices: OnboardingTutorialServicesType
    let tutorialServices: TutorialServicesType
    
    required init() {
        
        onboardingTutorialServices = OnboardingTutorialServices(languagePreferences: DeviceLanguagePreferences())
        tutorialServices = TutorialServices(languagePreferences: DeviceLanguagePreferences())
    }
}
