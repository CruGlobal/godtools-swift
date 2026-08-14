//
//  GetDeleteAccountStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetDeleteAccountStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is deleting their account.
        When: The delete account strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: DeleteAccountStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.deleteAccountTitle.key)")
        #expect(strings.subtitle == "\(argument.appLanguage):\(LocalizableStringKeys.deleteAccountSubtitle.key)")
        #expect(strings.confirmActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.deleteAccountConfirmButtonTitle.key)")
        #expect(strings.cancelActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.deleteAccountCancelButtonTitle.key)")
    }
}

extension GetDeleteAccountStringsUseCaseTests {

    private func getUseCase() -> GetDeleteAccountStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .deleteAccountTitle, .deleteAccountSubtitle, .deleteAccountConfirmButtonTitle, .deleteAccountCancelButtonTitle
        ]

        return GetDeleteAccountStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
