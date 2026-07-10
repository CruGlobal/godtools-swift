//
//  GetToolScreenShareQRCodeStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolScreenShareQRCodeStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing tool screen share qr code.
        When: The tool screen share qr code strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolScreenShareQRCodeStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.qrCodeDescription == "\(argument.appLanguage):\(LocalizableStringKeys.toolScreenShareQrCodeDescription.key)")
        #expect(strings.closeButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolScreenShareQrCodeCloseButtonTitle.key)")
    }
}

extension GetToolScreenShareQRCodeStringsUseCaseTests {

    private func getUseCase() -> GetToolScreenShareQRCodeStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.toolScreenShareQrCodeDescription, .toolScreenShareQrCodeCloseButtonTitle]

        return GetToolScreenShareQRCodeStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
