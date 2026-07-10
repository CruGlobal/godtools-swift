//
//  GetDashboardStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetDashboardStringsUseCaseTests {

    struct TestArgument {
        let translateInLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the dashboard.
        When: The dashboard strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: DashboardStringsDomainModel = useCase.execute(translateInLanguage: argument.translateInLanguage)

        #expect(strings.lessonsActionTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolMenuItemLessons.key)")
        #expect(strings.favoritesActionTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.myTools.key)")
        #expect(strings.toolsActionTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolMenuItemTools.key)")
    }
}

extension GetDashboardStringsUseCaseTests {

    private func getUseCase() -> GetDashboardStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.toolMenuItemLessons, .myTools, .toolMenuItemTools]

        return GetDashboardStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
