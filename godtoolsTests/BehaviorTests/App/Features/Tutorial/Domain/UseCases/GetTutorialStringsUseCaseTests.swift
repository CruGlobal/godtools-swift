//
//  GetTutorialStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetTutorialStringsUseCaseTests {

    @Test(
        """
        Given: User is viewing the tutorial in english.
        When: The tutorial strings are requested for the english app language.
        Then: The complete tutorial action uses the close tutorial title localized in english.
        """
    )
    func completeTutorialActionUsesCloseTutorialTitleForEnglish() {

        let useCase = getUseCase()

        let strings: TutorialStringsDomainModel = useCase.execute(appLanguage: LanguageCodeDomainModel.english.value)

        #expect(strings.nextTutorialPageActionTitle == "en:\(LocalizableStringKeys.tutorialContinueButtonTitleContinue.key)")
        #expect(strings.completeTutorialActionTitle == "en:\(LocalizableStringKeys.tutorialContinueButtonTitleCloseTutorial.key)")
    }

    @Test(
        """
        Given: User is viewing the tutorial in a non-english app language.
        When: The tutorial strings are requested for the spanish app language.
        Then: The complete tutorial action uses the start using GodTools title localized in spanish.
        """
    )
    func completeTutorialActionUsesStartUsingGodToolsTitleForNonEnglish() {

        let useCase = getUseCase()

        let strings: TutorialStringsDomainModel = useCase.execute(appLanguage: LanguageCodeDomainModel.spanish.value)

        #expect(strings.nextTutorialPageActionTitle == "es:\(LocalizableStringKeys.tutorialContinueButtonTitleContinue.key)")
        #expect(strings.completeTutorialActionTitle == "es:\(LocalizableStringKeys.tutorialContinueButtonTitleStartUsingGodTools.key)")
    }
}

extension GetTutorialStringsUseCaseTests {

    private func getUseCase() -> GetTutorialStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .tutorialContinueButtonTitleContinue, .tutorialContinueButtonTitleCloseTutorial, .tutorialContinueButtonTitleStartUsingGodTools
        ]

        return GetTutorialStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
