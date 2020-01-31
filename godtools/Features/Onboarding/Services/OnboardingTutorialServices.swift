//
//  OnboardingTutorialServices.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct OnboardingTutorialServices: OnboardingTutorialServicesType {
    
    private static let keyOnboardingTutorialDisabled: String = "keyOnboardingTutorialDisabled"
    
    private let languagePreferences: LanguagePreferencesType
    
    init(languagePreferences: LanguagePreferencesType) {
        self.languagePreferences = languagePreferences
    }
    
    var tutorialIsAvailable: Bool {
        return languagePreferences.isEnglish && !onboardingTutorialDisabled
    }
    
    private var onboardingTutorialDisabled: Bool {
        if let disabled = UserDefaults.getData(key: OnboardingTutorialServices.keyOnboardingTutorialDisabled) as? Bool {
            return disabled
        }
        return false
    }
    
    func enableOnboardingTutorial() {
        UserDefaults.saveData(
            data: nil,
            key: OnboardingTutorialServices.keyOnboardingTutorialDisabled
        )
    }
    
    func disableOnboardingTutorial() {
        UserDefaults.saveData(
            data: true,
            key: OnboardingTutorialServices.keyOnboardingTutorialDisabled
        )
    }
}
