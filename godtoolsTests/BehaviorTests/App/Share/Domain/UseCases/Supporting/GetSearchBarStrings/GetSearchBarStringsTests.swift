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
    func searchBarStringsTranslated() async {
                
        let getSearchBarStringsRepository = GetSearchBarStrings(localizationServices: Self.getLocalizationServices())
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishStringsRef: SearchBarStringsDomainModel?
        var spanishStringsRef: SearchBarStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            appLanguagePublisher
                .flatMap { appLanguage in
                    
                    return getSearchBarStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage)
                }.sink { strings in
                    
                    triggerCount += 1
                    
                    if triggerCount == 1 {
                        
                        englishStringsRef = strings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if triggerCount == 2 {
                        
                        spanishStringsRef = strings
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
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
