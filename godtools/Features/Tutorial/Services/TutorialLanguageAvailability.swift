//
//  TutorialLanguageAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialLanguageAvailability {
    
    let supportedLanguages: SupportedLanguagesType
        
    func isAvailableInLanguage(locale: Locale) -> Bool {
        
        if locale.languageCode != nil {
            
            for supportingLocale in supportedLanguages.languages {
                
                let languagesCodesMatch: Bool = locale.languageCode == supportingLocale.languageCode
                let scriptCodesMatch: Bool = (supportingLocale.scriptCode?.isEmpty ?? true) || supportingLocale.scriptCode == locale.scriptCode
                let regionCodesMatch: Bool = (supportingLocale.regionCode?.isEmpty ?? true) || supportingLocale.regionCode == locale.regionCode
                
                if languagesCodesMatch && scriptCodesMatch && regionCodesMatch {
                    return true
                }
            }
        }

        return false
    }
}
