//
//  GetReviewShareShareableStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetReviewShareShareableStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is reviewing a shareable to share.
        When: The review share shareable strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ReviewShareShareableStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.shareActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsShareImagePreviewShareImageButtonTitle.key)")
    }
}

extension GetReviewShareShareableStringsUseCaseTests {

    private func getUseCase() -> GetReviewShareShareableStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.toolSettingsShareImagePreviewShareImageButtonTitle]

        return GetReviewShareShareableStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
