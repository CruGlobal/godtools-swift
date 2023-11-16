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
    
    func getScriptName(forLanguageId: BCP47LanguageIdentifier, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        let languageLocale: Locale = Locale(identifier: forLanguageId)
        let languageScriptCode: String?
        
        if #available(iOS 16.0, *) {
            languageScriptCode = languageLocale.language.script?.identifier
        }
        else {
            languageScriptCode = languageLocale.scriptCode
        }
        
        guard let languageScriptCode = languageScriptCode else {
            return nil
        }
        
        return getScriptName(forScriptCode: languageScriptCode, translatedInLanguageId: translatedInLanguageId)
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
