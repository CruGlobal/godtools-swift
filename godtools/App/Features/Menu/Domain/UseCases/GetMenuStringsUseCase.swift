//
//  GetMenuStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetMenuStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    private let infoPlist: InfoPlistInterface
    
    init(localizationServices: LocalizationServicesInterface, infoPlist: InfoPlistInterface) {
        
        self.localizationServices = localizationServices
        self.infoPlist = infoPlist
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> MenuStringsDomainModel {

        let versionString: String

        if let appVersion = infoPlist.appVersion, let bundleVersion = infoPlist.bundleVersion {
            versionString = "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            versionString = ""
        }

        let titleKey: String = LocalizableStringKeys.settings.key
        let getStartedTitleKey: String = LocalizableStringKeys.menuGetStarted.key
        let tutorialOptionTitleKey: String = LocalizableStringKeys.menuTutorial.key
        let languageSettingsOptionTitleKey: String = LocalizableStringKeys.languageSettingsNavTitle.key
        let localizationSettingsOptionTitleKey: String = LocalizableStringKeys.menuLocalizationSettings.key
        let accountTitleKey: String = LocalizableStringKeys.menuAccount.key
        let loginOptionTitleKey: String = LocalizableStringKeys.login.key
        let createAccountOptionTitleKey: String = LocalizableStringKeys.createAccount.key
        let activityOptionTitleKey: String = LocalizableStringKeys.accountActivityTitle.key
        let logoutOptionTitleKey: String = LocalizableStringKeys.logout.key
        let deleteAccountOptionTitleKey: String = LocalizableStringKeys.menuDeleteAccount.key
        let supportTitleKey: String = LocalizableStringKeys.menuSupport.key
        let sendFeedbackOptionTitleKey: String = LocalizableStringKeys.menuSendFeedback.key
        let reportABugOptionTitleKey: String = LocalizableStringKeys.menuReportABug.key
        let askAQuestionOptionTitleKey: String = LocalizableStringKeys.menuAskAQuestion.key
        let shareTitleKey: String = LocalizableStringKeys.menuShare.key
        let leaveAReviewOptionTitleKey: String = LocalizableStringKeys.menuLeaveAReview.key
        let shareAStoryWithUsOptionTitleKey: String = LocalizableStringKeys.shareAStoryWithUs.key
        let shareGodToolsOptionTitleKey: String = LocalizableStringKeys.shareGodTools.key
        let aboutTitleKey: String = LocalizableStringKeys.menuAbout.key
        let termsOfUseOptionTitleKey: String = LocalizableStringKeys.termsOfUse.key
        let privacyPolicyOptionTitleKey: String = LocalizableStringKeys.privacyPolicy.key
        let copyrightInfoOptionTitleKey: String = LocalizableStringKeys.copyrightInfo.key
        let versionTitleKey: String = LocalizableStringKeys.menuVersion.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                getStartedTitleKey,
                tutorialOptionTitleKey,
                languageSettingsOptionTitleKey,
                localizationSettingsOptionTitleKey,
                accountTitleKey,
                loginOptionTitleKey,
                createAccountOptionTitleKey,
                activityOptionTitleKey,
                logoutOptionTitleKey,
                deleteAccountOptionTitleKey,
                supportTitleKey,
                sendFeedbackOptionTitleKey,
                reportABugOptionTitleKey,
                askAQuestionOptionTitleKey,
                shareTitleKey,
                leaveAReviewOptionTitleKey,
                shareAStoryWithUsOptionTitleKey,
                shareGodToolsOptionTitleKey,
                aboutTitleKey,
                termsOfUseOptionTitleKey,
                privacyPolicyOptionTitleKey,
                copyrightInfoOptionTitleKey,
                versionTitleKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return MenuStringsDomainModel(
            title: strings[titleKey] ?? "",
            getStartedTitle: strings[getStartedTitleKey] ?? "",
            tutorialOptionTitle: strings[tutorialOptionTitleKey] ?? "",
            languageSettingsOptionTitle: strings[languageSettingsOptionTitleKey] ?? "",
            localizationSettingsOptionTitle: strings[localizationSettingsOptionTitleKey] ?? "",
            accountTitle: strings[accountTitleKey] ?? "",
            loginOptionTitle: strings[loginOptionTitleKey] ?? "",
            createAccountOptionTitle: strings[createAccountOptionTitleKey] ?? "",
            activityOptionTitle: strings[activityOptionTitleKey] ?? "",
            logoutOptionTitle: strings[logoutOptionTitleKey] ?? "",
            deleteAccountOptionTitle: strings[deleteAccountOptionTitleKey] ?? "",
            supportTitle: strings[supportTitleKey] ?? "",
            sendFeedbackOptionTitle: strings[sendFeedbackOptionTitleKey] ?? "",
            reportABugOptionTitle: strings[reportABugOptionTitleKey] ?? "",
            askAQuestionOptionTitle: strings[askAQuestionOptionTitleKey] ?? "",
            shareTitle: strings[shareTitleKey] ?? "",
            leaveAReviewOptionTitle: strings[leaveAReviewOptionTitleKey] ?? "",
            shareAStoryWithUsOptionTitle: strings[shareAStoryWithUsOptionTitleKey] ?? "",
            shareGodToolsOptionTitle: strings[shareGodToolsOptionTitleKey] ?? "",
            aboutTitle: strings[aboutTitleKey] ?? "",
            termsOfUseOptionTitle: strings[termsOfUseOptionTitleKey] ?? "",
            privacyPolicyOptionTitle: strings[privacyPolicyOptionTitleKey] ?? "",
            copyrightInfoOptionTitle: strings[copyrightInfoOptionTitleKey] ?? "",
            versionTitle: strings[versionTitleKey] ?? "",
            version: versionString
        )
    }
}
