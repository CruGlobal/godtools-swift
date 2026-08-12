//
//  GetDownloadableLanguagesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetDownloadableLanguagesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the downloadable languages.
        When: The downloadable languages strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: DownloadableLanguagesStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.navTitle == "\(argument.appLanguage):\(LocalizableStringKeys.languageSettingsDownloadableLanguagesTitle.key)")
    }
}

extension GetDownloadableLanguagesStringsUseCaseTests {

    private func getUseCase() -> GetDownloadableLanguagesStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.languageSettingsDownloadableLanguagesTitle]

        return GetDownloadableLanguagesStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
