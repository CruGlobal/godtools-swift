//
//  GetTutorialIsAvailableUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetTutorialIsAvailableUseCaseTests {

    @Test(
        """
        Given: User's app language has a full tutorial.
        When: Checking if the tutorial is available.
        Then: The tutorial should be available.
        """,
        arguments: [
            LanguageCodeDomainModel.afrikaans,
            LanguageCodeDomainModel.english,
            LanguageCodeDomainModel.spanish,
            LanguageCodeDomainModel.indonesian,
            LanguageCodeDomainModel.latvian,
            LanguageCodeDomainModel.vietnamese
        ]
    )
    func tutorialIsAvailableForFullTutorialAppLanguages(languageCode: LanguageCodeDomainModel) {

        let useCase: GetTutorialIsAvailableUseCase = getUseCase()

        let isAvailable: Bool = useCase.execute(appLanguage: languageCode.value)

        #expect(isAvailable == true)
    }

    @Test(
        """
        Given: User's app language has a partial tutorial.
        When: Checking if the tutorial is available.
        Then: The tutorial should be available.
        """,
        arguments: [
            LanguageCodeDomainModel.amharic,
            LanguageCodeDomainModel.arabic,
            LanguageCodeDomainModel.bangla,
            LanguageCodeDomainModel.chineseSimplified,
            LanguageCodeDomainModel.chineseTraditional,
            LanguageCodeDomainModel.french,
            LanguageCodeDomainModel.german,
            LanguageCodeDomainModel.hausa,
            LanguageCodeDomainModel.hindi,
            LanguageCodeDomainModel.japanese,
            LanguageCodeDomainModel.korean,
            LanguageCodeDomainModel.nepali,
            LanguageCodeDomainModel.oromo,
            LanguageCodeDomainModel.portuguese,
            LanguageCodeDomainModel.romanian,
            LanguageCodeDomainModel.russian,
            LanguageCodeDomainModel.swahili,
            LanguageCodeDomainModel.urdu
        ]
    )
    func tutorialIsAvailableForPartialTutorialAppLanguages(languageCode: LanguageCodeDomainModel) {

        let useCase: GetTutorialIsAvailableUseCase = getUseCase()

        let isAvailable: Bool = useCase.execute(appLanguage: languageCode.value)

        #expect(isAvailable == true)
    }

    @Test(
        """
        Given: User's app language does not have a tutorial.
        When: Checking if the tutorial is available.
        Then: The tutorial should not be available.
        """,
        arguments: [
            LanguageCodeDomainModel.chinese.value,
            LanguageCodeDomainModel.czech.value,
            LanguageCodeDomainModel.filipino.value,
            LanguageCodeDomainModel.finnish.value,
            LanguageCodeDomainModel.hebrew.value,
            "unknown_language_code"
        ]
    )
    func tutorialIsNotAvailableForAppLanguagesWithoutATutorial(appLanguage: AppLanguageDomainModel) {

        let useCase: GetTutorialIsAvailableUseCase = getUseCase()

        let isAvailable: Bool = useCase.execute(appLanguage: appLanguage)

        #expect(isAvailable == false)
    }
}

// MARK: - Test Helpers

extension GetTutorialIsAvailableUseCaseTests {

    private func getUseCase() -> GetTutorialIsAvailableUseCase {

        return GetTutorialIsAvailableUseCase(
            getTutorialType: GetTutorialType()
        )
    }
}
