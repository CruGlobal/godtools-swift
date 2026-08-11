//
//  GetLessonSwipeTutorialStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLessonSwipeTutorialStringsUseCaseTests {

    struct TestArgument {
        let translateInLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the lesson swipe tutorial.
        When: The lesson swipe tutorial strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: LessonSwipeTutorialStringsDomainModel = await useCase.execute(translateInLanguage: argument.translateInLanguage)

        #expect(strings.title == "\(argument.translateInLanguage):\(LocalizableStringKeys.lessonsSwipeTutorialTitle.key)")
        #expect(strings.closeButtonText == "\(argument.translateInLanguage):\(LocalizableStringKeys.lessonsSwipeTutorialButtonText.key)")
    }
}

extension GetLessonSwipeTutorialStringsUseCaseTests {

    private func getUseCase() -> GetLessonSwipeTutorialStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.lessonsSwipeTutorialTitle, .lessonsSwipeTutorialButtonText]

        return GetLessonSwipeTutorialStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
