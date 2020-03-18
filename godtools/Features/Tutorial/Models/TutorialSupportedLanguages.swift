//
//  TutorialSupportedLanguages.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialSupportedLanguages: TutorialSupportedLanguagesType {
    
    let supportedLanguageCodes: [String] = ["en", "es", "zh"]
    
    func supportsLanguageCode(code: String) -> Bool {
        return supportedLanguageCodes.contains(code)
    }
    
    func supportsLanguageCode(fromLanguageCodes: [String]) -> Bool {
        for languageCode in fromLanguageCodes {
            if supportedLanguageCodes.contains(languageCode) {
                return true
            }
        }
        return false
    }
}
