//
//  GetMenuStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetMenuStringsUseCaseTests {

    private let englishAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    private let spanishAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.value

    @Test(
        """
        Given: User is viewing the menu
        When: The menu strings are requested for the english app language
        Then: Each menu string is localized for the english app language
        """
    )
    func menuStringsAreLocalizedForTheRequestedAppLanguage() async {

        let useCase = getUseCase()

        let menuStrings: MenuStringsDomainModel = await useCase.execute(appLanguage: englishAppLanguage)

        #expect(menuStrings.title == "en:\(LocalizableStringKeys.settings.key)")
        #expect(menuStrings.getStartedTitle == "en:\(LocalizableStringKeys.menuGetStarted.key)")
        #expect(menuStrings.tutorialOptionTitle == "en:\(LocalizableStringKeys.menuTutorial.key)")
        #expect(menuStrings.languageSettingsOptionTitle == "en:\(LocalizableStringKeys.languageSettingsNavTitle.key)")
        #expect(menuStrings.localizationSettingsOptionTitle == "en:\(LocalizableStringKeys.menuLocalizationSettings.key)")
        #expect(menuStrings.accountTitle == "en:\(LocalizableStringKeys.menuAccount.key)")
        #expect(menuStrings.loginOptionTitle == "en:\(LocalizableStringKeys.login.key)")
        #expect(menuStrings.createAccountOptionTitle == "en:\(LocalizableStringKeys.createAccount.key)")
        #expect(menuStrings.activityOptionTitle == "en:\(LocalizableStringKeys.accountActivityTitle.key)")
        #expect(menuStrings.logoutOptionTitle == "en:\(LocalizableStringKeys.logout.key)")
        #expect(menuStrings.deleteAccountOptionTitle == "en:\(LocalizableStringKeys.menuDeleteAccount.key)")
        #expect(menuStrings.supportTitle == "en:\(LocalizableStringKeys.menuSupport.key)")
        #expect(menuStrings.sendFeedbackOptionTitle == "en:\(LocalizableStringKeys.menuSendFeedback.key)")
        #expect(menuStrings.reportABugOptionTitle == "en:\(LocalizableStringKeys.menuReportABug.key)")
        #expect(menuStrings.askAQuestionOptionTitle == "en:\(LocalizableStringKeys.menuAskAQuestion.key)")
        #expect(menuStrings.shareTitle == "en:\(LocalizableStringKeys.menuShare.key)")
        #expect(menuStrings.leaveAReviewOptionTitle == "en:\(LocalizableStringKeys.menuLeaveAReview.key)")
        #expect(menuStrings.shareAStoryWithUsOptionTitle == "en:\(LocalizableStringKeys.shareAStoryWithUs.key)")
        #expect(menuStrings.shareGodToolsOptionTitle == "en:\(LocalizableStringKeys.shareGodTools.key)")
        #expect(menuStrings.aboutTitle == "en:\(LocalizableStringKeys.menuAbout.key)")
        #expect(menuStrings.termsOfUseOptionTitle == "en:\(LocalizableStringKeys.termsOfUse.key)")
        #expect(menuStrings.privacyPolicyOptionTitle == "en:\(LocalizableStringKeys.privacyPolicy.key)")
        #expect(menuStrings.copyrightInfoOptionTitle == "en:\(LocalizableStringKeys.copyrightInfo.key)")
        #expect(menuStrings.versionTitle == "en:\(LocalizableStringKeys.menuVersion.key)")
    }

    @Test(
        """
        Given: User is viewing the menu in a non-english app language
        When: The menu strings are requested for the spanish app language
        Then: Each menu string is localized for the spanish app language rather than english
        """
    )
    func menuStringsAreLocalizedForANonEnglishAppLanguage() async {

        let useCase = getUseCase()

        let menuStrings: MenuStringsDomainModel = await useCase.execute(appLanguage: spanishAppLanguage)

        #expect(menuStrings.title == "es:\(LocalizableStringKeys.settings.key)")
        #expect(menuStrings.getStartedTitle == "es:\(LocalizableStringKeys.menuGetStarted.key)")
        #expect(menuStrings.aboutTitle == "es:\(LocalizableStringKeys.menuAbout.key)")
        #expect(menuStrings.versionTitle == "es:\(LocalizableStringKeys.menuVersion.key)")
    }

    struct VersionStringArgument {
        let appVersion: String?
        let bundleVersion: String?
        let expectedVersion: String
    }

    @Test(
        """
        Given: User is viewing the menu
        When: The menu strings are requested with app and bundle version values from the info plist
        Then: The version string is formatted when both values exist, otherwise it is empty
        """,
        arguments: [
            VersionStringArgument(appVersion: "1.2.3", bundleVersion: "456", expectedVersion: "v1.2.3 (456)"),
            VersionStringArgument(appVersion: "10.0.0", bundleVersion: "1", expectedVersion: "v10.0.0 (1)"),
            VersionStringArgument(appVersion: nil, bundleVersion: "456", expectedVersion: ""),
            VersionStringArgument(appVersion: "1.2.3", bundleVersion: nil, expectedVersion: ""),
            VersionStringArgument(appVersion: nil, bundleVersion: nil, expectedVersion: "")
        ]
    )
    func versionStringIsFormattedFromInfoPlistVersions(argument: VersionStringArgument) async {

        let useCase = getUseCase(
            appVersion: argument.appVersion,
            bundleVersion: argument.bundleVersion
        )

        let menuStrings: MenuStringsDomainModel = await useCase.execute(appLanguage: englishAppLanguage)

        #expect(menuStrings.version == argument.expectedVersion)
    }
}

extension GetMenuStringsUseCaseTests {

    private func getUseCase(appVersion: String? = nil, bundleVersion: String? = nil) -> GetMenuStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .settings, .menuGetStarted, .menuTutorial, .languageSettingsNavTitle, .menuLocalizationSettings,
            .menuAccount, .login, .createAccount, .accountActivityTitle, .logout, .menuDeleteAccount,
            .menuSupport, .menuSendFeedback, .menuReportABug, .menuAskAQuestion, .menuShare, .menuLeaveAReview,
            .shareAStoryWithUs, .shareGodTools, .menuAbout, .termsOfUse, .privacyPolicy, .copyrightInfo, .menuVersion
        ]

        return GetMenuStringsUseCase(
            localizationServices: FakeLocalizationServices(
                localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish])
            ),
            infoPlist: FakeInfoPlist(appVersion: appVersion, bundleVersion: bundleVersion)
        )
    }
}
