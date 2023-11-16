//
//  LocaleLanguageScriptName.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocaleLanguageScriptName {
    
    init() {
        
    }
    
    func getScriptName(forScriptCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        let translateInLocale: Locale
        
        if let translatedInLanguageId = translatedInLanguageId, !translatedInLanguageId.isEmpty {
            translateInLocale = Locale(identifier: translatedInLanguageId)
        }
        else {
            translateInLocale = Locale(identifier: forScriptCode)
        }
    
        return translateInLocale.localizedString(forScriptCode: forScriptCode)
    }
}
