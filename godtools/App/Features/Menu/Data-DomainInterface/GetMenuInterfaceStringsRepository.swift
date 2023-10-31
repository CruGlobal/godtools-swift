//
//  GetMenuInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetMenuInterfaceStringsRepository: GetMenuInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    private let infoPlist: InfoPlist
    
    init(localizationServices: LocalizationServices, infoPlist: InfoPlist) {
        
        self.localizationServices = localizationServices
        self.infoPlist = infoPlist
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<MenuInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let versionString: String
        
        if let appVersion = infoPlist.appVersion, let bundleVersion = infoPlist.bundleVersion {
            versionString = "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            versionString = ""
        }
        
        let interfaceStrings = MenuInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "settings"),
            getStartedTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SectionTitles.getStarted.rawValue),
            tutorialOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.tutorial.rawValue),
            languageSettingsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.languageSettings.rawValue),
            accountTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SectionTitles.account.rawValue),
            loginOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.login.rawValue),
            createAccountOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.createAccount.rawValue),
            activityOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.activity.rawValue),
            logoutOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.logout.rawValue),
            deleteAccountOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.deleteAccount.rawValue),
            supportTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SectionTitles.support.rawValue),
            sendFeedbackOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.sendFeedback.rawValue),
            reportABugOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.reportABug.rawValue),
            askAQuestionOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.askAQuestion.rawValue),
            shareTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SectionTitles.share.rawValue),
            leaveAReviewOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.leaveAReview.rawValue),
            shareAStoryWithUsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.shareAStoryWithUs.rawValue),
            shareGodToolsOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.shareGodTools.rawValue),
            aboutTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SectionTitles.about.rawValue),
            termsOfUseOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.termsOfUse.rawValue),
            privacyPolicyOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.privacyPolicy.rawValue),
            copyrightInfoOptionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.ItemTitles.copyrightInfo.rawValue),
            versionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SectionTitles.account.rawValue),
            version: versionString
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
