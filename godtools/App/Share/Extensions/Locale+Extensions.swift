//
//  Locale+Extensions.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension Locale {
    
    var isBaseLanguage: Bool {
        
        let regionCodeIsEmpty: Bool = regionCode?.isEmpty ?? true
        let scriptCodeIsEmpty: Bool = scriptCode?.isEmpty ?? true
        let isBaseLanguage: Bool = regionCodeIsEmpty && scriptCodeIsEmpty
        
        return isBaseLanguage
    }
    
    var isEnglishLanguage: Bool {
        return languageCode == "en"
    }
    
    private func languageCodeIsEqualToLocaleLanguageCode(locale: Locale) -> Bool {
        
        let languageCodesMatch: Bool
        
        if let languageCode = languageCode, let localeLanguageCode = locale.languageCode, !languageCode.isEmpty, !localeLanguageCode.isEmpty {
            languageCodesMatch = languageCode.lowercased() == localeLanguageCode.lowercased()
        }
        else {
            languageCodesMatch = false
        }
        
        return languageCodesMatch
    }
    
    func isEqualTo(locale: Locale) -> Bool {
        
        let languageCodesMatch: Bool = languageCodeIsEqualToLocaleLanguageCode(locale: locale)
        let scriptCodesMatch: Bool = locale.scriptCode?.lowercased() == scriptCode?.lowercased()
        let regionCodesMatch: Bool = locale.regionCode?.lowercased() == regionCode?.lowercased()
        
        return languageCodesMatch && scriptCodesMatch && regionCodesMatch
    }
    
    func baseLanguageIsEqualToLocaleBaseLanguage(locale: Locale) -> Bool {
        
        return languageCodeIsEqualToLocaleLanguageCode(locale: locale)
    }
}
