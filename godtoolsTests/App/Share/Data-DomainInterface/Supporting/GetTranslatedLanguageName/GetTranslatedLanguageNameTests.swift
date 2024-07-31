//
//  GetTranslatedLanguageNameTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Quick
import Nimble

class GetTranslatedLanguageNameTests: QuickSpec {
    
    override class func spec() {
                
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.english.rawValue: "Inglés",
                LanguageCodeDomainModel.french.rawValue: "Francés",
                LanguageCodeDomainModel.spanish.rawValue: "Español",
                LanguageCodeDomainModel.russian.rawValue: "Ruso"
            ]
        ]
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
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
                
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
            localeLanguageName: MockLocaleLanguageName(languageNames: languageNames),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        describe("User is viewing the russian language name.") {
            
            context("When translating the russian language name using an empty translation string and fallbackName is false.") {
                
                it("Then translate the russian language name using the fallbackName.") {
                    
                    let russianFallbackName: String = "Russian Fallback Name"
                    
                    let russianLanguage = MockTranslatableLanguage(
                        languageCode: LanguageCodeDomainModel.russian.rawValue,
                        localeId: LanguageCodeDomainModel.russian.rawValue,
                        fallbackName: russianFallbackName,
                        forceLanguageName: false,
                        regionCode: nil,
                        scriptCode: nil
                    )
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: russianLanguage,
                        translatedInLanguage: ""
                    )
                                        
                    expect(translation).to(equal(russianFallbackName))
                }
            }
        }
        
        describe("User is viewing the russian language name.") {
            
            context("When translating the russian language name in spanish and forceLanguageName is true and a translation is available in the app bundle's string phrases and in Locale.") {
                
                it("Then translate the russian language name using the fallbackName.") {
                    
                    let russianFallbackName: String = "Russian Fallback Name"
                    
                    let russianLanguage = MockTranslatableLanguage(
                        languageCode: LanguageCodeDomainModel.russian.rawValue,
                        localeId: LanguageCodeDomainModel.russian.rawValue,
                        fallbackName: russianFallbackName,
                        forceLanguageName: true,
                        regionCode: nil,
                        scriptCode: nil
                    )
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: russianLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.spanish.rawValue
                    )
                    
                    let translationFromAppBundle: String? = localizableStrings[LanguageCodeDomainModel.spanish.value]?[LanguageCodeDomainModel.russian.value]
                    let translationFromLocale: String? = languageNames[LanguageCodeDomainModel.russian.value]?[LanguageCodeDomainModel.spanish.value]
                    
                    expect(translation).to(equal(russianFallbackName))
                    expect(translationFromAppBundle).to(equal("Ruso"))
                    expect(translationFromLocale).to(equal("Ruso"))
                }
            }
        }
        
        describe("User is viewing the french language name.") {
            
            context("When translating the french language name in spanish and forceLanguageName is false and a translation is available in the app bundle's string phrases.") {
                
                it("Then translate the french language name using the app bundle's string phrases.") {
                    
                    let fallbackName: String = "French Fallback Name"
                    
                    let frenchLanguage = MockTranslatableLanguage(
                        languageCode: LanguageCodeDomainModel.french.rawValue,
                        localeId: LanguageCodeDomainModel.french.rawValue,
                        fallbackName: fallbackName,
                        forceLanguageName: false,
                        regionCode: nil,
                        scriptCode: nil
                    )
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: frenchLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.spanish.rawValue
                    )
                    
                    let translationFromLocale: String? = languageNames[LanguageCodeDomainModel.french.value]?[LanguageCodeDomainModel.spanish.value]
                    
                    expect(translation).to(equal(localizableStrings[LanguageCodeDomainModel.spanish.value]?[LanguageCodeDomainModel.french.value]))
                    expect(translationFromLocale).to(equal("Francés"))
                }
            }
            
            context("When translating the french language name in czech and forceLanguageName is false and a translation is not available in the app bundle's string phrases, but available in Locale.") {
                
                it("Then translate the french language name using Locale.") {
                    
                    let fallbackName: String = "French Fallback Name"
                    
                    let frenchLanguage = MockTranslatableLanguage(
                        languageCode: LanguageCodeDomainModel.french.rawValue,
                        localeId: LanguageCodeDomainModel.french.rawValue,
                        fallbackName: fallbackName,
                        forceLanguageName: false,
                        regionCode: nil,
                        scriptCode: nil
                    )
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: frenchLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.czech.rawValue
                    )
                    
                    let translationFromAppBundle: String? = localizableStrings[LanguageCodeDomainModel.czech.value]?[LanguageCodeDomainModel.french.value]
                    
                    expect(translation).to(equal("francouzština"))
                    expect(translationFromAppBundle).to(beNil())
                }
            }
            
            context("When translating the french language name in arabic and forceLanguageName is false and a translation is not available in the app bundle's string phrases or in Locale.") {
                
                it("Then translate the french language using the fallbackName.") {
                             
                    let fallbackName: String = "French Fallback Name"
                    
                    let frenchLanguage = MockTranslatableLanguage(
                        languageCode: LanguageCodeDomainModel.french.rawValue,
                        localeId: LanguageCodeDomainModel.french.rawValue,
                        fallbackName: fallbackName,
                        forceLanguageName: false,
                        regionCode: nil,
                        scriptCode: nil
                    )
                    
                    let translationFromAppBundle: String? = localizableStrings[LanguageCodeDomainModel.arabic.value]?[LanguageCodeDomainModel.french.value]
                    let translationFromLocale: String? = languageNames[LanguageCodeDomainModel.french.value]?[LanguageCodeDomainModel.arabic.value]
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: frenchLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.arabic.rawValue
                    )
                    
                    expect(translation).to(equal(fallbackName))
                    expect(translationFromAppBundle).to(beNil())
                    expect(translationFromLocale).to(beNil())
                }
            }
        }
    }
}

