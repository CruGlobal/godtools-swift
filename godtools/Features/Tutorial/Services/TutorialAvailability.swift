//
//  TutorialAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialAvailability: TutorialAvailabilityType {
        
    private let tutorialLanguageAvailability: TutorialLanguageAvailability
    
    init(tutorialSupportedLanguages: SupportedLanguagesType) {
        
        tutorialLanguageAvailability = TutorialLanguageAvailability(supportedLanguages: tutorialSupportedLanguages)
    }
    
    var tutorialIsAvailable: Bool {        
        return tutorialLanguageAvailability.isAvailableInLanguage(locale: Locale.current)
    }
}
