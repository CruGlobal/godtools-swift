//
//  TutorialAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialAvailability: TutorialAvailabilityType {
        
    private let deviceLanguage: DeviceLanguageType
    private let tutorialLanguageAvailability: TutorialLanguageAvailability
    
    required init(deviceLanguage: DeviceLanguageType, tutorialSupportedLanguages: SupportedLanguagesType) {
        
        self.deviceLanguage = deviceLanguage
        self.tutorialLanguageAvailability = TutorialLanguageAvailability(supportedLanguages: tutorialSupportedLanguages)
    }
    
    var tutorialIsAvailable: Bool {
        
        return tutorialLanguageAvailability.isAvailableInLanguage(locale: deviceLanguage.preferredLocalizationLocale ?? deviceLanguage.locale)
    }
}
