//
//  GetToolFilterCategoriesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolFilterCategoriesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tool filter categories.
        When: The tool filter categories strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolFilterCategoriesStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.navTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolsFilterCategoryNavTitle.key)")
    }
}

extension GetToolFilterCategoriesStringsUseCaseTests {

    private func getUseCase() -> GetToolFilterCategoriesStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.toolsFilterCategoryNavTitle]

        return GetToolFilterCategoriesStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
