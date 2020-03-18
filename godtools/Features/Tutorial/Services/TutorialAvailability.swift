//
//  TutorialAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialAvailability: TutorialAvailabilityType {
    
    private let tutorialSupportedLanguages: TutorialSupportedLanguagesType
    
    init(tutorialSupportedLanguages: TutorialSupportedLanguagesType) {
        
        self.tutorialSupportedLanguages = tutorialSupportedLanguages
    }
    
    var tutorialIsAvailable: Bool {
        
        // TODO: Inlcude all preferred language codes?
        
        let languageCode: String = Locale.current.languageCode ?? Locale.preferredLanguages.first ?? ""
        let languageCodeIsSupported: Bool = tutorialSupportedLanguages.supportsLanguageCode(code: languageCode)
        
        return languageCodeIsSupported
    }
}
