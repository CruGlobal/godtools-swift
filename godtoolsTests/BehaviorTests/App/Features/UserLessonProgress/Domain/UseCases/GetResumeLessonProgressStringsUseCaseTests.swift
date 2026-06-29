//
//  GetResumeLessonProgressStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetResumeLessonProgressStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is resuming an in progress lesson.
        When: The resume lesson progress strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ResumeLessonProgressStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.lessonsResumeLessonModalTitle.key)")
        #expect(strings.subtitle == "\(argument.appLanguage):\(LocalizableStringKeys.lessonsResumeLessonModalSubtitle.key)")
        #expect(strings.startOverButtonText == "\(argument.appLanguage):\(LocalizableStringKeys.lessonsResumeLessonModalStartOverButton.key)")
        #expect(strings.continueButtonText == "\(argument.appLanguage):\(LocalizableStringKeys.lessonsResumeLessonModalContinueButton.key)")
    }
}

extension GetResumeLessonProgressStringsUseCaseTests {

    private func getUseCase() -> GetResumeLessonProgressStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .lessonsResumeLessonModalTitle, .lessonsResumeLessonModalSubtitle,
            .lessonsResumeLessonModalStartOverButton, .lessonsResumeLessonModalContinueButton
        ]

        return GetResumeLessonProgressStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
