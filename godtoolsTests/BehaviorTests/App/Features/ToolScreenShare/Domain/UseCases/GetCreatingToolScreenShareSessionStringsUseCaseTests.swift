//
//  GetCreatingToolScreenShareSessionStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetCreatingToolScreenShareSessionStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is creating a tool screen share session.
        When: The creating tool screen share session strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: CreatingToolScreenShareSessionStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.creatingSessionMessage == "\(argument.appLanguage):\(LocalizableStringKeys.loadToolRemoteSessionMessage.key)")
    }
}

extension GetCreatingToolScreenShareSessionStringsUseCaseTests {

    private func getUseCase() -> GetCreatingToolScreenShareSessionStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.loadToolRemoteSessionMessage]

        return GetCreatingToolScreenShareSessionStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
