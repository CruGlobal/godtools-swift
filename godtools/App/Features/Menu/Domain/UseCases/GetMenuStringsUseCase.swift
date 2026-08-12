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
    
    func execute(appLanguage: AppLanguageDomainModel) async -> MenuStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let versionString: String
        
        if let appVersion = infoPlist.appVersion, let bundleVersion = infoPlist.bundleVersion {
            versionString = "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            versionString = ""
        }
        
        let strings = MenuStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.settings.key),
            getStartedTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuGetStarted.key),
            tutorialOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuTutorial.key),
            languageSettingsOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key),
            localizationSettingsOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuLocalizationSettings.key),
            accountTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuAccount.key),
            loginOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.login.key),
            createAccountOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.createAccount.key),
            activityOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityTitle.key),
            logoutOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.logout.key),
            deleteAccountOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuDeleteAccount.key),
            supportTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuSupport.key),
            sendFeedbackOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuSendFeedback.key),
            reportABugOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuReportABug.key),
            askAQuestionOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuAskAQuestion.key),
            shareTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuShare.key),
            leaveAReviewOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuLeaveAReview.key),
            shareAStoryWithUsOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareAStoryWithUs.key),
            shareGodToolsOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareGodTools.key),
            aboutTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuAbout.key),
            termsOfUseOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.termsOfUse.key),
            privacyPolicyOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.privacyPolicy.key),
            copyrightInfoOptionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.copyrightInfo.key),
            versionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuVersion.key),
            version: versionString
        )
        
        return strings
    }
}
