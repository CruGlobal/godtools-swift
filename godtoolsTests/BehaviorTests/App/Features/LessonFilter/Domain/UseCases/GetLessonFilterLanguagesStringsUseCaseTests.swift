//
//  GetLessonFilterLanguagesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLessonFilterLanguagesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the lesson filter languages.
        When: The lesson filter languages strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) {

        let useCase = getUseCase()

        let strings: LessonFilterLanguagesStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.navTitle == "\(argument.appLanguage):\(LocalizableStringKeys.lessonsFilterLanguageNavTitle.key)")
    }
}

extension GetLessonFilterLanguagesStringsUseCaseTests {

    private func getUseCase() -> GetLessonFilterLanguagesStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.lessonsFilterLanguageNavTitle]

        return GetLessonFilterLanguagesStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
