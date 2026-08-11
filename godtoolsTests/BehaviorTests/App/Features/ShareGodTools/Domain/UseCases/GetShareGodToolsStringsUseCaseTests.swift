//
//  GetShareGodToolsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetShareGodToolsStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is sharing GodTools.
        When: The share GodTools strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ShareGodToolsStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.shareMessage == "\(argument.appLanguage):\(LocalizableStringKeys.shareGodToolsShareSheetText.key)")
    }
}

extension GetShareGodToolsStringsUseCaseTests {

    private func getUseCase() -> GetShareGodToolsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.shareGodToolsShareSheetText]

        return GetShareGodToolsStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
