//
//  TutorialLanguageAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialLanguageAvailability {
    
    let supportedLanguages: TutorialSupportedLanguagesType
       
    required init(supportedLanguages: TutorialSupportedLanguagesType) {
        
        self.supportedLanguages = supportedLanguages
    }
    
    func isAvailableInLanguage(locale: Locale) -> Bool {
                           
        for supportingLocale in supportedLanguages.languages {
            
            let baseLanguagesMatch: Bool = supportingLocale.baseLanguageIsEqualToLocaleBaseLanguage(locale: locale)
            
            guard baseLanguagesMatch else {
                continue
            }
            
            let supportingLocaleHasScriptCode: Bool = supportingLocale.scriptCode != nil
            let supportingLocaleHasRegionCode: Bool = supportingLocale.regionCode != nil
            
            if supportingLocale.isBaseLanguage && baseLanguagesMatch {
                return true
            }
            else if supportingLocaleHasScriptCode && supportingLocaleHasRegionCode {
                if supportingLocale.scriptCodeIsEqualToLocaleScriptCode(locale: locale) && supportingLocale.regionCodeIsEqualToLocaleRegionCode(locale: locale) {
                    return true
                }
            }
            else if supportingLocaleHasScriptCode {
                if supportingLocale.scriptCodeIsEqualToLocaleScriptCode(locale: locale) {
                    return true
                }
            }
            else if supportingLocaleHasRegionCode {
                if supportingLocale.regionCodeIsEqualToLocaleRegionCode(locale: locale) {
                    return true
                }
            }
        }
        
        return false
    }
}
