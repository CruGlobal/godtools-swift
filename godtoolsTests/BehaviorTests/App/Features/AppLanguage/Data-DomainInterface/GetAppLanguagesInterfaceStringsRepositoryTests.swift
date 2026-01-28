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

struct GetAppLanguagesInterfaceStringsRepositoryTests {
    
    @Test(
        """
        Given: User is viewing the app languages.
        When: The app language is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    func interfaceStringsTranslateWhenAppLanguageChanges() async {
        
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
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var englishInterfaceStringsRef: AppLanguagesInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: AppLanguagesInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
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
                            
                            // When finished be sure to call:
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(englishInterfaceStringsRef?.navTitle == "App Language")
        
        #expect(spanishInterfaceStringsRef?.navTitle == "Idioma de la aplicación")
    }
}
