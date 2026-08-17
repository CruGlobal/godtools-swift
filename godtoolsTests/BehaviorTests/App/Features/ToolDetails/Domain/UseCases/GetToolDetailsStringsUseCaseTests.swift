//
//  GetToolDetailsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolDetailsStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tool details.
        When: The tool details strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) {

        let useCase = getUseCase()

        let strings: ToolDetailsStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.aboutActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolDetailsAboutTitle.key)")
        #expect(strings.addToFavoritesActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.addToFavorites.key)")
        #expect(strings.bibleReferencesTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolDetailsBibleReferencesTitle.key)")
        #expect(strings.conversationStartersTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolDetailsConversationStartersTitle.key)")
        #expect(strings.languagesAvailableTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsLanguagesAvailableTitle.key)")
        #expect(strings.learnToShareThisToolActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolDetailsLearnToShareToolButtonTitle.key)")
        #expect(strings.openToolActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolinfoOpentool.key)")
        #expect(strings.outlineTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolDetailsOutlineTitle.key)")
        #expect(strings.removeFromFavoritesActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.removeFromFavorites.key)")
        #expect(strings.versionsActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolDetailsVersionsTitle.key)")
    }
}

extension GetToolDetailsStringsUseCaseTests {

    private func getUseCase() -> GetToolDetailsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .toolDetailsAboutTitle, .addToFavorites, .toolDetailsBibleReferencesTitle, .toolDetailsConversationStartersTitle,
            .toolSettingsLanguagesAvailableTitle, .toolDetailsLearnToShareToolButtonTitle, .toolinfoOpentool,
            .toolDetailsOutlineTitle, .removeFromFavorites, .toolDetailsVersionsTitle
        ]

        return GetToolDetailsStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
