//
//  GetToolSettingsToolLanguagesListStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolSettingsToolLanguagesListStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tool settings tool languages list.
        When: The tool settings tool languages list strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolSettingsToolLanguagesListStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.deleteParallelLanguageActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsLanguagesListDeleteLanguageTitle.key)")
    }
}

extension GetToolSettingsToolLanguagesListStringsUseCaseTests {

    private func getUseCase() -> GetToolSettingsToolLanguagesListStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.toolSettingsLanguagesListDeleteLanguageTitle]

        return GetToolSettingsToolLanguagesListStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
