//
//  TutorialLanguageAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialLanguageAvailability: LanguageAvailabilityType {
    
    let supportedLanguages: SupportedLanguagesType
       
    required init(supportedLanguages: SupportedLanguagesType) {
        
        self.supportedLanguages = supportedLanguages
    }
    
    func isAvailableInLanguage(locale: Locale) -> Bool {
                        
        for supportingLocale in supportedLanguages.languages {
            if locale.isEqualTo(locale: supportingLocale) || (supportingLocale.isBaseLanguage && locale.baseLanguageIsEqualToLocaleBaseLanguage(locale: supportingLocale)) {
                return true
            }
        }
        
        return false
    }
    
    func isAvailableInLanguages(identifiers: [String]) -> Bool {
        for identifier in identifiers {
            if isAvailableInLanguage(locale: Locale(identifier: identifier)) {
                return true
            }
        }
        return false
    }
}
