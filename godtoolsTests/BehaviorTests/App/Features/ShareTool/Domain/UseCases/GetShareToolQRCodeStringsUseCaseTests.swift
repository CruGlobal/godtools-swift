//
//  GetShareToolQRCodeStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetShareToolQRCodeStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the share tool QR code.
        When: The share tool QR code strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ShareToolQRCodeStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.message == "\(argument.appLanguage):\(LocalizableStringKeys.shareToolQrCodeMessage.key)")
        #expect(strings.closeActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolScreenShareQrCodeCloseButtonTitle.key)")
    }
}

extension GetShareToolQRCodeStringsUseCaseTests {

    private func getUseCase() -> GetShareToolQRCodeStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.shareToolQrCodeMessage, .toolScreenShareQrCodeCloseButtonTitle]

        return GetShareToolQRCodeStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
