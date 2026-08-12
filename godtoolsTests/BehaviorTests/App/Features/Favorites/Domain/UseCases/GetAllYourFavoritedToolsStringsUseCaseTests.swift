//
//  GetAllYourFavoritedToolsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetAllYourFavoritedToolsStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing all of their favorited tools.
        When: The all your favorited tools strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: AllYourFavoritedToolsStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.sectionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesFavoriteToolsTitle.key)")
    }
}

extension GetAllYourFavoritedToolsStringsUseCaseTests {

    private func getUseCase() -> GetAllYourFavoritedToolsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.favoritesFavoriteToolsTitle]

        return GetAllYourFavoritedToolsStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
