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
    
    private static let frenchCanadaLocaleId: BCP47LanguageIdentifier = "fr-CA"
    private static let canadaRegionCode: String = "CA"
    
    private static let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
        LanguageCodeDomainModel.spanish.value: [
            LanguageCodeDomainModel.english.rawValue: "Inglés",
            LanguageCodeDomainModel.french.rawValue: "Francés",
            LanguageCodeDomainModel.spanish.rawValue: "Español",
            LanguageCodeDomainModel.russian.rawValue: "Ruso"
        ]
    ]
    
    private static let languageNames: [FakeLocaleLanguageName.LanguageCode: [FakeLocaleLanguageName.TranslateInLocaleId: FakeLocaleLanguageName.LanguageName]] = [
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
            
    struct GetLanguageNamePairTestArgument {
        let language: FakeTranslatableLanguage
        let appLanguage: AppLanguageDomainModel
        let expectedNameInOwnLanguage: String
        let expectedNameInAppLanguage: String
    }
    
    private static let getTranslatedLanguageName = GetTranslatedLanguageName(
        localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: FakeLocalizationServices(localizableStrings: localizableStrings)),
        localeLanguageName: FakeLocaleLanguageName(languageNames: languageNames),
        localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
        localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
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
        
        let russianLanguage = FakeTranslatableLanguage(
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
        
        let russianLanguage = FakeTranslatableLanguage(
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
        
        let frenchLanguage = FakeTranslatableLanguage(
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
        
        let frenchLanguage = FakeTranslatableLanguage(
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
        
        let frenchLanguage = FakeTranslatableLanguage(
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
    
    @Test(
        """
        Given: User is viewing a list of language names.
        When: Getting the language name pair translated in the app language.
        Then: The pair contains the language name translated in its own language and translated in the app language.
        """,
        arguments: [
            GetLanguageNamePairTestArgument(
                language: FakeTranslatableLanguage(
                    languageCode: LanguageCodeDomainModel.russian.rawValue,
                    localeId: LanguageCodeDomainModel.russian.rawValue,
                    fallbackName: "Russian Fallback Name",
                    forceLanguageName: false,
                    regionCode: nil,
                    scriptCode: nil
                ),
                appLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedNameInOwnLanguage: "Русский",
                expectedNameInAppLanguage: "Ruso"
            ),
            GetLanguageNamePairTestArgument(
                language: FakeTranslatableLanguage(
                    languageCode: LanguageCodeDomainModel.english.rawValue,
                    localeId: LanguageCodeDomainModel.english.rawValue,
                    fallbackName: "English Fallback Name",
                    forceLanguageName: false,
                    regionCode: nil,
                    scriptCode: nil
                ),
                appLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedNameInOwnLanguage: "English",
                expectedNameInAppLanguage: "Inglés"
            ),
            GetLanguageNamePairTestArgument(
                language: FakeTranslatableLanguage(
                    languageCode: LanguageCodeDomainModel.french.rawValue,
                    localeId: LanguageCodeDomainModel.french.rawValue,
                    fallbackName: "French Fallback Name",
                    forceLanguageName: false,
                    regionCode: nil,
                    scriptCode: nil
                ),
                appLanguage: LanguageCodeDomainModel.czech.rawValue,
                expectedNameInOwnLanguage: "French Fallback Name",
                expectedNameInAppLanguage: "francouzština"
            ),
            GetLanguageNamePairTestArgument(
                language: FakeTranslatableLanguage(
                    languageCode: LanguageCodeDomainModel.russian.rawValue,
                    localeId: LanguageCodeDomainModel.russian.rawValue,
                    fallbackName: "Russian Fallback Name",
                    forceLanguageName: true,
                    regionCode: nil,
                    scriptCode: nil
                ),
                appLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedNameInOwnLanguage: "Russian Fallback Name",
                expectedNameInAppLanguage: "Russian Fallback Name"
            )
        ]
    )
    func getsLanguageNamePair(argument: GetLanguageNamePairTestArgument) {
        
        let namePair: TranslatedLanguageNamePairDomainModel = Self.getTranslatedLanguageName.getLanguageNamePair(
            language: argument.language,
            appLanguage: argument.appLanguage
        )
        
        #expect(namePair.nameInOwnLanguage == argument.expectedNameInOwnLanguage)
        #expect(namePair.nameInAppLanguage == argument.expectedNameInAppLanguage)
    }
    
    @Test(
        """
        Given: User is viewing a language name that includes a region.
        When: Getting the language name pair translated in the app language.
        Then: Both names in the pair include the region suffix translated in their respective language.
        """
    )
    func getsLanguageNamePairWithRegionSuffix() {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: FakeLocalizationServices(localizableStrings: [:])),
            localeLanguageName: FakeLocaleLanguageName(languageNames: [
                LanguageCodeDomainModel.french.rawValue: [
                    Self.frenchCanadaLocaleId: "français",
                    LanguageCodeDomainModel.spanish.rawValue: "Francés"
                ]
            ]),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [
                Self.canadaRegionCode: [
                    Self.frenchCanadaLocaleId: "Canada",
                    LanguageCodeDomainModel.spanish.rawValue: "Canadá"
                ]
            ]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )
        
        let frenchCanadaLanguage = FakeTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.french.rawValue,
            localeId: Self.frenchCanadaLocaleId,
            fallbackName: "French Fallback Name",
            forceLanguageName: false,
            regionCode: Self.canadaRegionCode,
            scriptCode: nil
        )
        
        let namePair: TranslatedLanguageNamePairDomainModel = getTranslatedLanguageName.getLanguageNamePair(
            language: frenchCanadaLanguage,
            appLanguage: LanguageCodeDomainModel.spanish.rawValue
        )
        
        #expect(namePair.nameInOwnLanguage == "français (Canada)")
        #expect(namePair.nameInAppLanguage == "Francés (Canadá)")
    }
}
