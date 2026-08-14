//
//  GetLessonEvaluationStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLessonEvaluationStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User has completed a lesson and is evaluating it.
        When: The lesson evaluation strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: LessonEvaluationStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.lessonEvaluationTitle.key)")
        #expect(strings.wasThisHelpful == "\(argument.appLanguage):\(LocalizableStringKeys.lessonEvaluationWasThisHelpful.key)")
        #expect(strings.yesActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.yes.key)")
        #expect(strings.noActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.no.key)")
        #expect(strings.shareFaithReadiness == "\(argument.appLanguage):\(LocalizableStringKeys.lessonEvaluationShareFaith.key)")
        #expect(strings.sendFeedbackActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.lessonEvaluationSendButtonTitle.key)")
    }
}

extension GetLessonEvaluationStringsUseCaseTests {

    private func getUseCase() -> GetLessonEvaluationStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .lessonEvaluationTitle, .lessonEvaluationWasThisHelpful, .yes, .no,
            .lessonEvaluationShareFaith, .lessonEvaluationSendButtonTitle
        ]

        return GetLessonEvaluationStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
