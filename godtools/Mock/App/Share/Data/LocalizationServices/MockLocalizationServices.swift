//
//  MockLocalizationServices.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

class MockLocalizationServices: LocalizationServicesInterface {
    
    typealias LocaleId = StringKey
    typealias StringKey = String
    
    private let localizableStrings: [LocaleId: [StringKey: String]]
    
    init(localizableStrings: [LocaleId: [StringKey: String]]) {
        
        self.localizableStrings = localizableStrings
    }
    
    static func getLocalizedLanguageNames() -> [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] {
        
        return [
            LanguageCodeDomainModel.english.value: [
                LanguageCodeDomainModel.afrikaans.rawValue: "Afrikaans",
                LanguageCodeDomainModel.arabic.rawValue: "Arabic",
                LanguageCodeDomainModel.czech.rawValue: "Czech",
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.french.rawValue: "French",
                LanguageCodeDomainModel.hebrew.rawValue: "Hebrew",
                LanguageCodeDomainModel.spanish.rawValue: "Spanish",
                LanguageCodeDomainModel.russian.rawValue: "Russian",
                LanguageCodeDomainModel.vietnamese.rawValue: "Vietnamese"
            ],
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.afrikaans.rawValue: "africaans",
                LanguageCodeDomainModel.arabic.rawValue: "Arábica",
                LanguageCodeDomainModel.czech.rawValue: "Checo",
                LanguageCodeDomainModel.english.rawValue: "Inglés",
                LanguageCodeDomainModel.french.rawValue: "Francés",
                LanguageCodeDomainModel.hebrew.rawValue: "Hebreo",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "Ruso",
                LanguageCodeDomainModel.vietnamese.rawValue: "vietnamita"
            ],
            LanguageCodeDomainModel.russian.value: [
                LanguageCodeDomainModel.afrikaans.rawValue: "африкаанс",
                LanguageCodeDomainModel.arabic.rawValue: "арабский",
                LanguageCodeDomainModel.czech.rawValue: "Чешский",
                LanguageCodeDomainModel.english.rawValue: "Английский",
                LanguageCodeDomainModel.french.rawValue: "Французский",
                LanguageCodeDomainModel.hebrew.rawValue: "иврит",
                LanguageCodeDomainModel.spanish.rawValue: "испанский",
                LanguageCodeDomainModel.russian.rawValue: "Русский",
                LanguageCodeDomainModel.vietnamese.rawValue: "вьетнамский"
            ]
        ]
    }
    
    static func createLanguageNamesLocalizationServices(addAdditionalLocalizableStrings: [LocaleId: [StringKey: String]]? = nil) -> MockLocalizationServices {
        
        var mutableLocalizedLanguageNames: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = getLocalizedLanguageNames()

        if let addAdditionalLocalizableStrings = addAdditionalLocalizableStrings, !addAdditionalLocalizableStrings.isEmpty {
            
            for (localeId, localeIdStrings) in addAdditionalLocalizableStrings {
                
                var mutableLocaleIdStrings: [StringKey: StringKey] = localeIdStrings
                
                for (key, value) in mutableLocaleIdStrings {
                    if mutableLocaleIdStrings[key] == nil {
                        mutableLocaleIdStrings[key] = value
                    }
                }
                
                mutableLocalizedLanguageNames[localeId] = mutableLocaleIdStrings
            }
        }
        
        return MockLocalizationServices(
            localizableStrings: mutableLocalizedLanguageNames
        )
    }
    
    func stringForLocale(localeIdentifier: String?, key: String) -> String? {
        
        guard let localeIdentifier = localeIdentifier else {
            return ""
        }
        
        guard let localizedStrings = localizableStrings[localeIdentifier] else {
            return ""
        }
        
        return localizedStrings[key]
    }
    
    func stringForEnglish(key: String) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: "en", key: key)
    }
    
    func stringForSystemElseEnglish(key: String) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: "en", key: key)
    }
    
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String) -> String {
        
        guard let localeIdentifier = localeIdentifier else {
            return ""
        }
        
        guard let localizedStrings = localizableStrings[localeIdentifier] else {
            return ""
        }
        
        return localizedStrings[key] ?? ""
    }
    
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: key)
    }
}
