//
//  GetSearchBarStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetSearchBarStringsUseCaseTests {
    
    private let cancelButtonKey: String = "cancel"
    private let cancelButtonTextEnglish: String = "Cancel"
    private let cancelButtonTextSpanish: String = "Cancelar"
    
    @Test(
        """
        Given: User is viewing a search bar.
        When: The app language is set to Spanish
        Then: The search bar interface strings should be translated in Spanish
        """
    )
    func searchBarStringsTranslated() async {
                
        let getSearchBarStrings = GetSearchBarStringsUseCase(localizationServices: getLocalizationServices())
        
        let strings = getSearchBarStrings
            .execute(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
        
        #expect(strings.cancel == cancelButtonTextSpanish)
    }
}

extension GetSearchBarStringsUseCaseTests {
    
    private func getLocalizationServices() -> MockLocalizationServices {
                
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                cancelButtonKey: cancelButtonTextEnglish
            ],
            LanguageCodeDomainModel.spanish.value: [
                cancelButtonKey: cancelButtonTextSpanish
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }
}
