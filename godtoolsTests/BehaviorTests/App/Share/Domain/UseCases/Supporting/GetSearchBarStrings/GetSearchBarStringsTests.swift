//
//  GetSearchBarStringsTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetSearchBarStringsTests {
    
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
    func TestsearchBarStringsTranslated() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getSearchBarStringsRepository = GetSearchBarStrings(localizationServices: Self.getLocalizationServices())
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishStringsRef: SearchBarStringsDomainModel?
        var spanishStringsRef: SearchBarStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getSearchBarStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage)
                }.sink { strings in
                    
                    sinkCount += 1
                    confirmation()
                    
                    if sinkCount == 1 {
                        
                        englishStringsRef = strings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if sinkCount == 2 {
                        
                        spanishStringsRef = strings
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(englishStringsRef?.cancel == Self.cancelButtonTextEnglish)
        #expect(spanishStringsRef?.cancel == Self.cancelButtonTextSpanish)
    }
}

extension GetSearchBarStringsTests {
    
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
