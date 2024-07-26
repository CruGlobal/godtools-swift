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
              
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        let frenchLanguage = MockTranslatableLanguage(
            languageCode: LanguageCodeDomainModel.french.rawValue,
            localeId: LanguageCodeDomainModel.french.rawValue,
            fallbackName: "French",
            regionCode: nil,
            scriptCode: nil
        )
        
        describe("User is viewing the french language name translated in spanish.") {
         
            context("If the spanish translation is available in the app bundle's string phrases.") {
                
                it("Display the language name from the app bundle's string phrases.") {
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: frenchLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.spanish.rawValue
                    )
                    
                    expect(translation).to(equal("Francés"))
                }
            }
        }
        
        describe("User is viewing the french language name translated in czech.") {
         
            context("If the czech translation is not available in the app bundle's string phrases, but available in Locale.") {
                
                it("Display the language name from Locale.") {
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: frenchLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.czech.rawValue
                    )
                    
                    expect(translation).to(equal("francouzština"))
                }
            }
        }
        
        describe("User is viewing the french language name translated in arabic.") {
         
            context("If the arabic translation is not available in the app bundle's string phrases and is not available in Locale.") {
                
                it("Display the fallback name.") {
                    
                    let translation: String? = getTranslatedLanguageName.getLanguageName(
                        language: frenchLanguage,
                        translatedInLanguage: LanguageCodeDomainModel.arabic.rawValue
                    )
                    
                    expect(translation).to(equal("French"))
                }
            }
        }
    }
}

