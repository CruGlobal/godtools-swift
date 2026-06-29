//
//  GetLearnToShareToolStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLearnToShareToolStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is learning to share a tool.
        When: The learn to share tool strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: LearnToShareToolStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.nextTutorialItemActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.tutorialContinueButtonTitleContinue.key)")
        #expect(strings.startTrainingActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.startTraining.key)")
    }
}

extension GetLearnToShareToolStringsUseCaseTests {

    private func getUseCase() -> GetLearnToShareToolStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.tutorialContinueButtonTitleContinue, .startTraining]

        return GetLearnToShareToolStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
