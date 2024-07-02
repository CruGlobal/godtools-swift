//
//  GetTranslatedLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

class GetTranslatedLanguageName {
    
    private let localizationServices: LocalizationServicesInterface
    private let localeLanguageName: LocaleLanguageNameInterface
    private let localeRegionName: LocaleLanguageRegionNameInterface
    private let localeScriptName: LocaleLanguageScriptNameInterface
    
    init(localizationServices: LocalizationServicesInterface, localeLanguageName: LocaleLanguageNameInterface, localeRegionName: LocaleLanguageRegionNameInterface, localeScriptName: LocaleLanguageScriptNameInterface) {
        
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
        self.localeRegionName = localeRegionName
        self.localeScriptName = localeScriptName
    }
    
    func getLanguageName(language: TranslatableLanguage, translatedInLanguage: BCP47LanguageIdentifier) -> String {
        
        guard !translatedInLanguage.isEmpty else {
            return language.fallbackName
        }
        
        if let localizedName = getLanguageNameFromLocalization(language: language, translatedInLanguage: translatedInLanguage) {
            
            return localizedName
        }
        else if let localeLanguageName = getLanguageNameFromLocale(language: language, translatedInLanguage: translatedInLanguage) {
            
            return localeLanguageName
        }
        
        return language.fallbackName
    }
    
    private func getLanguageNameFromLocalization(language: TranslatableLanguage, translatedInLanguage: BCP47LanguageIdentifier) -> String? {
        
        let localizedKey: String = "language_name_" + language.localeId
        let localizedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInLanguage, key: localizedKey)
        
        guard !localizedName.isEmpty && localizedName != localizedKey else {
            return nil
        }
        
        return localizedName
    }
    
    private func getLanguageNameFromLocale(language: TranslatableLanguage, translatedInLanguage: BCP47LanguageIdentifier) -> String? {
            
        let languageName: String?
        
        var languageSuffixes: [String] = Array()
        
        if let localeLanguageName = localeLanguageName.getLanguageName(forLanguageCode: language.languageCode, translatedInLanguageId: translatedInLanguage), !localeLanguageName.isEmpty {
            languageName = localeLanguageName
        }
        else {
            languageName = localeLanguageName.getLanguageName(forLocaleId: language.localeId, translatedInLanguageId: translatedInLanguage)
        }
        
        guard let languageName = languageName else {
            return nil
        }
        
        if let scriptCode = language.scriptCode, let localeScriptName = localeScriptName.getScriptName(forScriptCode: scriptCode, translatedInLanguageId: translatedInLanguage) {
            languageSuffixes.append(localeScriptName)
        }
        else if let regionCode = language.regionCode, let localeRegionName = localeRegionName.getRegionName(forRegionCode: regionCode, translatedInLanguageId: translatedInLanguage) {
            languageSuffixes.append(localeRegionName)
        }
        
        guard languageSuffixes.count > 0 else {
            return languageName
        }
        
        var languageNameWithSuffix: String = languageName
        
        for suffix in languageSuffixes {
            languageNameWithSuffix += " (\(suffix))"
        }
        
        return languageNameWithSuffix
    }
}
