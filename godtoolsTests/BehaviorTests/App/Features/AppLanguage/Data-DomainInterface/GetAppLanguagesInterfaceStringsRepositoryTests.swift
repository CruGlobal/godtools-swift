//
//  GetAppLanguagesInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine


import Foundation
import Quick
import Nimble

struct GetAppLanguagesInterfaceStringsRepositoryTests {
    
    @Test(
        """
        Given: User is viewing the app languages.
        When: The app language is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    func interfaceStringsTranslateWhenAppLanguageChanges() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
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
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: AppLanguagesInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: AppLanguagesInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            appLanguagePublisher
                .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguagesInterfaceStringsDomainModel, Never> in
                    
                    return getAppLanguagesInterfaceStringsRepository
                        .getStringsPublisher(translateInLanguage: appLanguage)
                        .eraseToAnyPublisher()
                })
                .sink { (interfaceStrings: AppLanguagesInterfaceStringsDomainModel) in
                    
                    sinkCount += 1
                    confirmation()
                    
                    if sinkCount == 1 {
                        
                        englishInterfaceStringsRef = interfaceStrings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if sinkCount == 2 {
                        
                        spanishInterfaceStringsRef = interfaceStrings
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(englishInterfaceStringsRef?.navTitle == "App Language")
        
        #expect(spanishInterfaceStringsRef?.navTitle == "Idioma de la aplicación")
    }
}
