//
//  GetShareToolScreenShareSessionStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetShareToolScreenShareSessionStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is sharing a tool screen share session.
        When: The share tool screen share session strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ShareToolScreenShareSessionStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.shareMessage == "\(argument.appLanguage):\(LocalizableStringKeys.shareToolRemoteLinkMessage.key)")
        #expect(strings.qrCodeActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolScreenShareQrCodeTitle.key)")
    }
}

extension GetShareToolScreenShareSessionStringsUseCaseTests {

    private func getUseCase() -> GetShareToolScreenShareSessionStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.shareToolRemoteLinkMessage, .toolScreenShareQrCodeTitle]

        return GetShareToolScreenShareSessionStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
