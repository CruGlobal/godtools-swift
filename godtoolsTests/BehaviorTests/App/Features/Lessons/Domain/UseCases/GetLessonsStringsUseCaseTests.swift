//
//  GetLessonsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLessonsStringsUseCaseTests {

    struct TestArgument {
        let translateInLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the lessons.
        When: The lessons strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: LessonsStringsDomainModel = await useCase.execute(translateInLanguage: argument.translateInLanguage)

        #expect(strings.title == "\(argument.translateInLanguage):\(LocalizableStringKeys.lessonsPageTitle.key)")
        #expect(strings.subtitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.lessonsPageSubtitle.key)")
        #expect(strings.languageFilterTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.lessonsLanguageFilterTitle.key)")
        #expect(strings.personalizedToolToggleTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key)")
        #expect(strings.allLessonsToggleTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolToggleAllLessonsTitle.key)")
        #expect(strings.personalizedLessonExplanationTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedLessonFooterTitle.key)")
        #expect(strings.personalizedLessonExplanationSubtitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedLessonFooterSubtitle.key)")
        #expect(strings.changeLocalizationSettingsAction == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key)")
        #expect(strings.viewAllLessonsAction == "\(argument.translateInLanguage):\(LocalizableStringKeys.lessonsPersonalizationUnavailableViewAllLessons.key)")
    }
}

extension GetLessonsStringsUseCaseTests {

    private func getUseCase() -> GetLessonsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .lessonsPageTitle, .lessonsPageSubtitle, .lessonsLanguageFilterTitle,
            .dashboardPersonalizedToolTogglePersonalizedTitle, .dashboardPersonalizedToolToggleAllLessonsTitle,
            .dashboardPersonalizedLessonFooterTitle, .dashboardPersonalizedLessonFooterSubtitle,
            .dashboardPersonalizedToolFooterButtonTitle, .lessonsPersonalizationUnavailableViewAllLessons
        ]

        return GetLessonsStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
