//
//  GetFavoritesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetFavoritesStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing their favorites.
        When: The favorites strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: FavoritesStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.tutorialMessage == "\(argument.appLanguage):\(LocalizableStringKeys.openTutorialShowTutorialLabelText.key)")
        #expect(strings.openTutorialActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.openTutorialOpenTutorialButtonTitle.key)")
        #expect(strings.welcomeTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesPageTitle.key)")
        #expect(strings.featuredLessonsTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesFavoriteLessonsTitle.key)")
        #expect(strings.favoriteToolsTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesFavoriteToolsTitle.key)")
        #expect(strings.viewAllFavoritesActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesFavoriteToolsViewAll.key)")
        #expect(strings.noFavoritedToolsTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesNoToolsTitle.key)")
        #expect(strings.noFavoritedToolsDescription == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesNoToolsDescription.key)")
        #expect(strings.noFavoritedToolsActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.favoritesNoToolsButton.key)")
    }
}

extension GetFavoritesStringsUseCaseTests {

    private func getUseCase() -> GetFavoritesStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .openTutorialShowTutorialLabelText, .openTutorialOpenTutorialButtonTitle, .favoritesPageTitle,
            .favoritesFavoriteLessonsTitle, .favoritesFavoriteToolsTitle, .favoritesFavoriteToolsViewAll,
            .favoritesNoToolsTitle, .favoritesNoToolsDescription, .favoritesNoToolsButton
        ]

        return GetFavoritesStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
