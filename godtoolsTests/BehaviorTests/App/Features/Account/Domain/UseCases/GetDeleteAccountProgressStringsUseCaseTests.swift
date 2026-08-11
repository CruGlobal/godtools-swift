//
//  GetDeleteAccountProgressStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetDeleteAccountProgressStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is deleting their account.
        When: The delete account progress strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: DeleteAccountProgressStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.deleteAccountProgressTitle.key)")
    }
}

extension GetDeleteAccountProgressStringsUseCaseTests {

    private func getUseCase() -> GetDeleteAccountProgressStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.deleteAccountProgressTitle]

        return GetDeleteAccountProgressStringsUseCase(
            localizationServices: FakeLocalizationServices(
                localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish])
            )
        )
    }
}
