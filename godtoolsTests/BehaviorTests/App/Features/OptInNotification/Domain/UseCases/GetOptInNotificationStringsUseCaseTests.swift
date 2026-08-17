//
//  GetOptInNotificationStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetOptInNotificationStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is presented the opt in notification prompt.
        When: The opt in notification strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) {

        let useCase = getUseCase()

        let strings: OptInNotificationStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.optInNotificationTitle.key)")
        #expect(strings.body == "\(argument.appLanguage):\(LocalizableStringKeys.optInNotificationBody.key)")
        #expect(strings.allowNotificationsActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.optInNotificationAllowNotifications.key)")
        #expect(strings.notificationSettingsActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.optInNotificationNotificationSettings.key)")
        #expect(strings.maybeLaterActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.optInNotificationMaybeLater.key)")
    }
}

extension GetOptInNotificationStringsUseCaseTests {

    private func getUseCase() -> GetOptInNotificationStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .optInNotificationTitle, .optInNotificationBody, .optInNotificationAllowNotifications,
            .optInNotificationNotificationSettings, .optInNotificationMaybeLater
        ]

        return GetOptInNotificationStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
