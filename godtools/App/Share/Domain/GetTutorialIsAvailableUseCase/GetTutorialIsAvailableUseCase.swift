//
//  GetTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class GetTutorialIsAvailableUseCase {
    
    private let deviceLanguage: DeviceLanguageType
    private let tutorialLanguageAvailability: TutorialLanguageAvailability
    
    required init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
        self.tutorialLanguageAvailability = TutorialLanguageAvailability(supportedLanguages: TutorialSupportedLanguages())
    }
    
    func getTutorialIsAvailable() -> Bool {
        
        return tutorialLanguageAvailability.isAvailableInLanguage(locale: deviceLanguage.preferredLocalizationLocale ?? deviceLanguage.locale)
    }
}
