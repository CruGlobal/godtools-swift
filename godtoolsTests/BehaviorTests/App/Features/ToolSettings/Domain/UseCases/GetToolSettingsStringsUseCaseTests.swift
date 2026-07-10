//
//  GetToolSettingsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolSettingsStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tool settings.
        When: The tool settings strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolSettingsStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.chooseParallelLanguageActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsChooseLanguageNoParallelLanguageTitle.key)")
        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsTitle.key)")
        #expect(strings.shareLinkTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsOptionShareLinkTitle.key)")
        #expect(strings.screenShareTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsOptionScreenShareTitle.key)")
        #expect(strings.toolOptionEnableTrainingTips == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsOptionTrainingTipsShowTitle.key)")
        #expect(strings.toolOptionDisableTrainingTips == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsOptionTrainingTipsHideTitle.key)")
        #expect(strings.chooseLanguageTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsChooseLanguageTitle.key)")
        #expect(strings.chooseLanguageMessage == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsChooseLanguageToggleMessage.key)")
        #expect(strings.shareablesTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolSettingsShareablesTitle.key)")
    }
}

extension GetToolSettingsStringsUseCaseTests {

    private func getUseCase() -> GetToolSettingsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .toolSettingsChooseLanguageNoParallelLanguageTitle, .toolSettingsTitle, .toolSettingsOptionShareLinkTitle,
            .toolSettingsOptionScreenShareTitle, .toolSettingsOptionTrainingTipsShowTitle, .toolSettingsOptionTrainingTipsHideTitle,
            .toolSettingsChooseLanguageTitle, .toolSettingsChooseLanguageToggleMessage, .toolSettingsShareablesTitle
        ]

        return GetToolSettingsStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
