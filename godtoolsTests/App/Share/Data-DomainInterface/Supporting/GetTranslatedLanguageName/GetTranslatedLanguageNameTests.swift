//
//  GetTranslatedLanguageNameTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//


import Testing
@testable import godtools

struct GetTranslatedLanguageNameTests {
    
    struct TestArgument {
        let percentageValue: Double
        let expectedValue: String
    }
    
    private static let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
        LanguageCodeDomainModel.spanish.value: [
            LanguageCodeDomainModel.english.rawValue: "Inglés",
            LanguageCodeDomainModel.french.rawValue: "Francés",
            LanguageCodeDomainModel.spanish.rawValue: "Español",
            LanguageCodeDomainModel.russian.rawValue: "Ruso"
        ]
    ]
    
    private static let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
        LanguageCodeDomainModel.english.rawValue: [
            LanguageCodeDomainModel.english.rawValue: "English",
            LanguageCodeDomainModel.portuguese.rawValue: "Inglês",
            LanguageCodeDomainModel.spanish.rawValue: "Inglés",
            LanguageCodeDomainModel.russian.rawValue: "Английский"
        ],
        LanguageCodeDomainModel.french.rawValue: [
            LanguageCodeDomainModel.czech.rawValue: "francouzština",
            LanguageCodeDomainModel.english.rawValue: "French",
            LanguageCodeDomainModel.portuguese.rawValue: "Francês",
            LanguageCodeDomainModel.spanish.rawValue: "Francés",
            LanguageCodeDomainModel.russian.rawValue: "Французский"
        ],
        LanguageCodeDomainModel.spanish.rawValue: [
            LanguageCodeDomainModel.english.rawValue: "Spanish",
            LanguageCodeDomainModel.portuguese.rawValue: "Espanhol",
            LanguageCodeDomainModel.spanish.rawValue: "Español",
            LanguageCodeDomainModel.russian.rawValue: "испанский"
        ],
        LanguageCodeDomainModel.russian.rawValue: [
            LanguageCodeDomainModel.english.rawValue: "Russian",
            LanguageCodeDomainModel.portuguese.rawValue: "Russo",
            LanguageCodeDomainModel.spanish.rawValue: "Ruso",
            LanguageCodeDomainModel.russian.rawValue: "Русский"
        ]
    ]
            
    private static let getTranslatedLanguageName = GetTranslatedLanguageName(
        localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
        localeLanguageName: MockLocaleLanguageName(languageNames: languageNames),
        localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
        localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
    )
    
    @Test(
        """
        Given: User is viewing the russian language name.
        When: The language to translate to is an empty string and forceLanguageName is false. 
        Then: Use the fallback name.
        """
    )
    func emptyTranslateInLanguageUsesFallback() {
        
        let translateInLanguage: BCP47LanguageIdentifier = ""
        
        let russianFallbackName: String = "Russian Fallback Name"
        
        let russianLanguage = MockTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.russian.rawValue,
            localeId: LanguageCodeDomainModel.russian.rawValue,
            fallbackName: russianFallbackName,
            forceLanguageName: false,
            regionCode: nil,
            scriptCode: nil
        )
        
        let translation: String? = Self.getTranslatedLanguageName.getLanguageName(
            language: russianLanguage,
            translatedInLanguage: translateInLanguage
        )
        
        #expect(translation == russianFallbackName)
    }
    
    @Test(
        """
        Given: User is viewing the russian language name.
        When: Translating the russian language name in spanish and forceLanguageName is true and a translation is available in the app bundle's string phrases and in Locale.
        Then: Translate the russian language name using the fallbackName.
        """
    )
    func usesFallbackInsteadOfAppBundleAndLocale() {
       
        let russianFallbackName: String = "Russian Fallback Name"
        
        let russianLanguage = MockTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.russian.rawValue,
            localeId: LanguageCodeDomainModel.russian.rawValue,
            fallbackName: russianFallbackName,
            forceLanguageName: true,
            regionCode: nil,
            scriptCode: nil
        )
        
        let translation: String? = Self.getTranslatedLanguageName.getLanguageName(
            language: russianLanguage,
            translatedInLanguage: LanguageCodeDomainModel.spanish.rawValue
        )
        
        let translationFromAppBundle: String? = Self.localizableStrings[LanguageCodeDomainModel.spanish.value]?[LanguageCodeDomainModel.russian.value]
        let translationFromLocale: String? = Self.languageNames[LanguageCodeDomainModel.russian.value]?[LanguageCodeDomainModel.spanish.value]
        
        #expect(translation == russianFallbackName)
        #expect(translationFromAppBundle == "Ruso")
        #expect(translationFromLocale == "Ruso")
    }
    
    @Test(
        """
        Given: User is viewing the french language name.
        When: Translating the french language name in spanish and forceLanguageName is false and a translation is available in the app bundle's string phrases.
        Then: Translate the french language name using the app bundle's string phrases.
        """
    )
    func usesAppBundlesStringPhrases() {
        
        let fallbackName: String = "French Fallback Name"
        
        let frenchLanguage = MockTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.french.rawValue,
            localeId: LanguageCodeDomainModel.french.rawValue,
            fallbackName: fallbackName,
            forceLanguageName: false,
            regionCode: nil,
            scriptCode: nil
        )
        
        let translation: String? = Self.getTranslatedLanguageName.getLanguageName(
            language: frenchLanguage,
            translatedInLanguage: LanguageCodeDomainModel.spanish.rawValue
        )
        
        let translationFromLocale: String? = Self.languageNames[LanguageCodeDomainModel.french.value]?[LanguageCodeDomainModel.spanish.value]
        
        #expect(translation == Self.localizableStrings[LanguageCodeDomainModel.spanish.value]?[LanguageCodeDomainModel.french.value])
        #expect(translationFromLocale == "Francés")
    }
    
    @Test(
        """
        Given: User is viewing the french language name.
        When: Translating the french language name in czech and forceLanguageName is false and a translation is not available in the app bundle's string phrases, but available in Locale.
        Then: Then translate the french language name using Locale.
        """
    )
    func usesLocale() {
        
        let fallbackName: String = "French Fallback Name"
        
        let frenchLanguage = MockTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.french.rawValue,
            localeId: LanguageCodeDomainModel.french.rawValue,
            fallbackName: fallbackName,
            forceLanguageName: false,
            regionCode: nil,
            scriptCode: nil
        )
        
        let translation: String? = Self.getTranslatedLanguageName.getLanguageName(
            language: frenchLanguage,
            translatedInLanguage: LanguageCodeDomainModel.czech.rawValue
        )
        
        let translationFromAppBundle: String? = Self.localizableStrings[LanguageCodeDomainModel.czech.value]?[LanguageCodeDomainModel.french.value]
        
        #expect(translation == "francouzština")
        #expect(translationFromAppBundle == nil)
    }
    
    @Test(
        """
        Given: User is viewing the french language name.
        When: Translating the french language name in arabic and forceLanguageName is false and a translation is not available in the app bundle's string phrases or in Locale.
        Then: Then translate the french language using the fallbackName.
        """
    )
    func usesFallback() {
        
        let fallbackName: String = "French Fallback Name"
        
        let frenchLanguage = MockTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.french.rawValue,
            localeId: LanguageCodeDomainModel.french.rawValue,
            fallbackName: fallbackName,
            forceLanguageName: false,
            regionCode: nil,
            scriptCode: nil
        )
        
        let translationFromAppBundle: String? = Self.localizableStrings[LanguageCodeDomainModel.arabic.value]?[LanguageCodeDomainModel.french.value]
        let translationFromLocale: String? = Self.languageNames[LanguageCodeDomainModel.french.value]?[LanguageCodeDomainModel.arabic.value]
        
        let translation: String? = Self.getTranslatedLanguageName.getLanguageName(
            language: frenchLanguage,
            translatedInLanguage: LanguageCodeDomainModel.arabic.rawValue
        )
        
        #expect(translation == fallbackName)
        #expect(translationFromAppBundle == nil)
        #expect(translationFromLocale == nil)
    }
}
