//
//  GetLocalizationSettingsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLocalizationSettingsStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the localization settings.
        When: The localization settings strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: LocalizationSettingsStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.navTitle == "\(argument.appLanguage):\(LocalizableStringKeys.localizationSettingsNavBarTitle.key)")
        #expect(strings.localizationHeaderTitle == "\(argument.appLanguage):\(LocalizableStringKeys.localizationSettingsLocalizationHeaderTitle.key)")
        #expect(strings.localizationHeaderDescription == "\(argument.appLanguage):\(LocalizableStringKeys.localizationSettingsLocalizationHeaderDescription.key)")
    }
}

extension GetLocalizationSettingsStringsUseCaseTests {

    private func getUseCase() -> GetLocalizationSettingsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .localizationSettingsNavBarTitle, .localizationSettingsLocalizationHeaderTitle, .localizationSettingsLocalizationHeaderDescription
        ]

        return GetLocalizationSettingsStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
