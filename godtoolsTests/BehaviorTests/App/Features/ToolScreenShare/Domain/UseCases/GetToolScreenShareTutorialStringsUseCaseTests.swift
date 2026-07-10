//
//  GetToolScreenShareTutorialStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolScreenShareTutorialStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tool screen share tutorial.
        When: The tool screen share tutorial strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolScreenShareTutorialStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.generateQRCodeActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.screenShareTutorialGenerateQRCodeButtonTitle.key)")
        #expect(strings.nextTutorialPageActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.tutorialContinueButtonTitleContinue.key)")
        #expect(strings.shareLinkActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.shareLink.key)")
    }
}

extension GetToolScreenShareTutorialStringsUseCaseTests {

    private func getUseCase() -> GetToolScreenShareTutorialStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .screenShareTutorialGenerateQRCodeButtonTitle, .tutorialContinueButtonTitleContinue, .shareLink
        ]

        return GetToolScreenShareTutorialStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
