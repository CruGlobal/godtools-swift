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
