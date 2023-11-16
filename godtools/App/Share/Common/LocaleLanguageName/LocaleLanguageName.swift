//
//  LocaleLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocaleLanguageName {
    
    init() {
        
    }
    
    func getLanguageName(forLanguageId: BCP47LanguageIdentifier, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        let languageLocale: Locale = Locale(identifier: forLanguageId)
        let languageCode: String?
        
        if #available(iOS 16.0, *) {
            languageCode = languageLocale.language.languageCode?.identifier
        }
        else {
            languageCode = languageLocale.languageCode
        }
        
        guard let languageCode = languageCode else {
            return nil
        }
        
        return getLanguageName(forLanguageCode: languageCode, translatedInLanguageId: translatedInLanguageId)
    }
    
    func getLanguageName(forLanguageCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        let translateInLocale: Locale
        
        if let translatedInLanguageId = translatedInLanguageId, !translatedInLanguageId.isEmpty {
            translateInLocale = Locale(identifier: translatedInLanguageId)
        }
        else {
            translateInLocale = Locale(identifier: forLanguageCode)
        }
        
        return translateInLocale.localizedString(forLanguageCode: forLanguageCode)
    }
}
