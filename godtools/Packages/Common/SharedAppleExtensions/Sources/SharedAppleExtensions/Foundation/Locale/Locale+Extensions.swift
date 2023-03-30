//
//  Locale+Extensions.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

public extension Locale {
    
    var isBaseLanguage: Bool {
        
        let isBaseLanguage: Bool = isMissingRegionCode && isMissingScriptCode
        
        return isBaseLanguage
    }
    
    var isEnglishLanguage: Bool {
        return languageCode == "en"
    }
    
    var isMissingRegionCode: Bool {
        return regionCode?.isEmpty ?? true
    }
    
    var isMissingScriptCode: Bool {
        return scriptCode?.isEmpty ?? true
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
    
    func scriptCodeIsEqualToLocaleScriptCode(locale: Locale) -> Bool {
        return locale.scriptCode?.lowercased() == scriptCode?.lowercased()
    }
    
    func regionCodeIsEqualToLocaleRegionCode(locale: Locale) -> Bool {
        return locale.regionCode?.lowercased() == regionCode?.lowercased()
    }
    
    func isEqualTo(locale: Locale) -> Bool {
        
        let languageCodesMatch: Bool = languageCodeIsEqualToLocaleLanguageCode(locale: locale)
        let scriptCodesMatch: Bool = scriptCodeIsEqualToLocaleScriptCode(locale: locale)
        let regionCodesMatch: Bool = regionCodeIsEqualToLocaleRegionCode(locale: locale)
        
        return languageCodesMatch && scriptCodesMatch && regionCodesMatch
    }
    
    func baseLanguageIsEqualToLocaleBaseLanguage(locale: Locale) -> Bool {
        
        return languageCodeIsEqualToLocaleLanguageCode(locale: locale)
    }
    
    func baseLanguageAndScriptCodesAreEqualTo(locale: Locale) -> Bool {
        
        let baseLanguagesMatch: Bool = baseLanguageIsEqualToLocaleBaseLanguage(locale: locale)
        let scriptCodesMatch: Bool = locale.scriptCode?.lowercased() == scriptCode?.lowercased()
        
        return baseLanguagesMatch && scriptCodesMatch
    }
}
