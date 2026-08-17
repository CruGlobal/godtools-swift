//
//  FakeLocalizationServices.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

final class FakeLocalizationServices: LocalizationServicesInterface {
    
    static let english = LanguageCodeDomainModel.english
    static let spanish = LanguageCodeDomainModel.spanish
    
    typealias LocaleId = StringKey
    typealias StringKey = String
    
    private let localizableStrings: [LocaleId: [StringKey: String]]
    
    init(localizableStrings: [LocaleId: [StringKey: String]]) {
        
        self.localizableStrings = localizableStrings
    }
    
    static func getLocalizedLanguageNames() -> [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] {
        
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
    
    static func createLanguageNamesLocalizationServices(
        addAdditionalLocalizableStrings: [LocaleId: [StringKey: String]]? = nil
    ) -> FakeLocalizationServices {
        
        var mutableLocalizedLanguageNames: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = getLocalizedLanguageNames()

        if let addAdditionalLocalizableStrings = addAdditionalLocalizableStrings {
            
            Self.mergeLocalizableStrings(
                localizableStrings: addAdditionalLocalizableStrings,
                intoStrings: &mutableLocalizedLanguageNames
            )
        }
        
        return FakeLocalizationServices(
            localizableStrings: mutableLocalizedLanguageNames
        )
    }
    
    static func getStrings(
        stringKeys: [LocalizableStringKeys],
        languages: [LanguageCodeDomainModel]
    ) -> [LocaleId: [StringKey: String]] {

        var localizableStrings: [LocaleId: [StringKey: String]] = Dictionary()
        
        for language in languages {
            
            var stringsForLanguage: [String: String] = Dictionary()
            
            for stringKey in stringKeys {
                stringsForLanguage[stringKey.key] = "\(language.rawValue):\(stringKey.key)"
            }

            localizableStrings[language.rawValue] = stringsForLanguage
        }
        
        return localizableStrings
    }
    
    static func mergeLocalizableStrings(
        localizableStrings: [LocaleId: [StringKey: String]],
        intoStrings: inout [LocaleId: [StringKey: String]]
    ) {
        
        guard !localizableStrings.isEmpty else {
            return
        }
        
        for (localeId, strings) in localizableStrings {
            
            guard !strings.isEmpty else {
                continue
            }
            
            var newStringsDictionary: [StringKey: StringKey] = intoStrings[localeId] ?? Dictionary()
            
            for (key, value) in strings {
                newStringsDictionary[key] = value
            }
            
            intoStrings[localeId] = newStringsDictionary
        }
    }
    
    func stringForEnglishElseKey(key: String) -> String {
        
        return localizableStrings[Self.english.rawValue]?[key] ?? key
    }
    
    private func stringForLocale(localeIdentifier: String?, key: String) -> String? {
        
        guard let localeIdentifier = localeIdentifier else {
            return ""
        }
        
        guard let localizedStrings = localizableStrings[localeIdentifier] else {
            return ""
        }
        
        return localizedStrings[key]
    }
}
