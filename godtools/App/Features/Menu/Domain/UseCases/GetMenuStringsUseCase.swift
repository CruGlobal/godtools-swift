//
//  GetMenuStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetMenuStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let infoPlist: InfoPlistInterface
    
    init(localizationServices: LocalizationServicesInterface, infoPlist: InfoPlistInterface) {
        
        self.localizationServices = localizationServices
        self.infoPlist = infoPlist
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> MenuStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let versionString: String
        
        if let appVersion = infoPlist.appVersion, let bundleVersion = infoPlist.bundleVersion {
            versionString = "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            versionString = ""
        }
        
        let strings = MenuStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.settings.key),
            getStartedTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuGetStarted.key),
            tutorialOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuTutorial.key),
            languageSettingsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.languageSettingsNavTitle.key),
            localizationSettingsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuLocalizationSettings.key),
            accountTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuAccount.key),
            loginOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.login.key),
            createAccountOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.createAccount.key),
            activityOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityTitle.key),
            logoutOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.logout.key),
            deleteAccountOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuDeleteAccount.key),
            supportTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuSupport.key),
            sendFeedbackOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuSendFeedback.key),
            reportABugOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuReportABug.key),
            askAQuestionOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuAskAQuestion.key),
            shareTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuShare.key),
            leaveAReviewOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuLeaveAReview.key),
            shareAStoryWithUsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareAStoryWithUs.key),
            shareGodToolsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareGodTools.key),
            aboutTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuAbout.key),
            termsOfUseOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.termsOfUse.key),
            privacyPolicyOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.privacyPolicy.key),
            copyrightInfoOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.copyrightInfo.key),
            versionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.menuVersion.key),
            version: versionString
        )
        
        return strings
    }
}
