//
//  GetSearchBarInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetSearchBarInterfaceStringsRepositoryTests {
    
    private static let cancelButtonKey: String = "cancel"
    private static let cancelButtonTextEnglish: String = "Cancel"
    private static let cancelButtonTextSpanish: String = "Cancelar"
    
    @Test(
        """
        Given: User is viewing a search bar in English
        When: The app language is switched from English to Spanish
        Then: The search bar interface strings should be translated in Spanish
        """
    )
    func TestsearchBarInterfaceStringsTranslated() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getSearchBarInterfaceStringsRepository = GetSearchBarInterfaceStringsRepository(localizationServices: Self.getLocalizationServices())
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: SearchBarInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: SearchBarInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getSearchBarInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage)
                }.sink { interfaceStrings in
                    
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
        
        #expect(englishInterfaceStringsRef?.cancel == Self.cancelButtonTextEnglish)
        #expect(spanishInterfaceStringsRef?.cancel == Self.cancelButtonTextSpanish)
    }
}

extension GetSearchBarInterfaceStringsRepositoryTests {
    
    private static func getLocalizationServices() -> MockLocalizationServices {
                
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                Self.cancelButtonKey: Self.cancelButtonTextEnglish
            ],
            LanguageCodeDomainModel.spanish.value: [
                Self.cancelButtonKey: Self.cancelButtonTextSpanish
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
}
