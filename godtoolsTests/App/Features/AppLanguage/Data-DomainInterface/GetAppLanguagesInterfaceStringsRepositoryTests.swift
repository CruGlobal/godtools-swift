//
//  GetAppLanguagesInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetAppLanguagesInterfaceStringsRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        describe("When a user is viewing the app languages.") {
         
            context("When the app language is switched from English to Spanish.") {
                
                let navTitleKey: String = "languageSettings.appLanguage.title"
                
                let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
                    LanguageCodeDomainModel.english.value: [
                        navTitleKey: "App Language"
                    ],
                    LanguageCodeDomainModel.spanish.value: [
                        navTitleKey: "Idioma de la aplicación"
                    ]
                ]
                
                let getAppLanguagesInterfaceStringsRepository = GetAppLanguagesInterfaceStringsRepository(
                    localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)
                )
                
                it("The interface strings should be translated into Spanish.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishInterfaceStringsRef: AppLanguagesInterfaceStringsDomainModel?
                    var spanishInterfaceStringsRef: AppLanguagesInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = appLanguagePublisher
                            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguagesInterfaceStringsDomainModel, Never> in
                                
                                return getAppLanguagesInterfaceStringsRepository
                                    .getStringsPublisher(translateInLanguage: appLanguage)
                                    .eraseToAnyPublisher()
                            })
                            .sink { (interfaceStrings: AppLanguagesInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    englishInterfaceStringsRef = interfaceStrings
                                }
                                else if sinkCount == 2 {
                                    
                                    spanishInterfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                                                                
                                if sinkCount == 1 {
                                    appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                                }
                            }
                    }

                    expect(englishInterfaceStringsRef?.navTitle).to(equal("App Language"))
                    
                    expect(spanishInterfaceStringsRef?.navTitle).to(equal("Idioma de la aplicación"))
                }
            }
        }
    }
}

