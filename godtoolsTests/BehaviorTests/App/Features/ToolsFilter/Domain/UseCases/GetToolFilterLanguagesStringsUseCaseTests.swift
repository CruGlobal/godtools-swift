//
//  GetToolFilterLanguagesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolFilterLanguagesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tool filter languages.
        When: The tool filter languages strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolFilterLanguagesStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.navTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolsFilterLanguageNavTitle.key)")
    }
}

extension GetToolFilterLanguagesStringsUseCaseTests {

    private func getUseCase() -> GetToolFilterLanguagesStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.toolsFilterLanguageNavTitle]

        return GetToolFilterLanguagesStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
