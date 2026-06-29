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

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing a search bar.
        When: The search bar strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: SearchBarStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.cancel == "\(argument.appLanguage):\(LocalizableStringKeys.cancel.key)")
    }
}

extension GetSearchBarStringsUseCaseTests {

    private func getUseCase() -> GetSearchBarStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.cancel]

        return GetSearchBarStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
