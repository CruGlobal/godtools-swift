//
//  Locale+Extensions.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension Locale {
    
    public var isBaseLanguage: Bool {
        
        let isBaseLanguage: Bool = isMissingRegionCode && isMissingScriptCode
        
        return isBaseLanguage
    }
    
    public var isEnglishLanguage: Bool {
        return languageCode == "en"
    }
    
    public var isMissingRegionCode: Bool {
        return regionCode?.isEmpty ?? true
    }
    
    public var isMissingScriptCode: Bool {
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
    
    public func scriptCodeIsEqualToLocaleScriptCode(locale: Locale) -> Bool {
        return locale.scriptCode?.lowercased() == scriptCode?.lowercased()
    }
    
    public func regionCodeIsEqualToLocaleRegionCode(locale: Locale) -> Bool {
        return locale.regionCode?.lowercased() == regionCode?.lowercased()
    }
    
    public func isEqualTo(locale: Locale) -> Bool {
        
        let languageCodesMatch: Bool = languageCodeIsEqualToLocaleLanguageCode(locale: locale)
        let scriptCodesMatch: Bool = scriptCodeIsEqualToLocaleScriptCode(locale: locale)
        let regionCodesMatch: Bool = regionCodeIsEqualToLocaleRegionCode(locale: locale)
        
        return languageCodesMatch && scriptCodesMatch && regionCodesMatch
    }
    
    public func baseLanguageIsEqualToLocaleBaseLanguage(locale: Locale) -> Bool {
        
        return languageCodeIsEqualToLocaleLanguageCode(locale: locale)
    }
    
    public func baseLanguageAndScriptCodesAreEqualTo(locale: Locale) -> Bool {
        
        let baseLanguagesMatch: Bool = baseLanguageIsEqualToLocaleBaseLanguage(locale: locale)
        let scriptCodesMatch: Bool = locale.scriptCode?.lowercased() == scriptCode?.lowercased()
        
        return baseLanguagesMatch && scriptCodesMatch
    }
}
