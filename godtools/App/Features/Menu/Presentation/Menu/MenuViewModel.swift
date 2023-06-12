//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class MenuViewModel: ObservableObject {
    
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String
    @Published var getStartedSectionTitle: String
    @Published var accountSectionTitle: String
    @Published var supportSectionTitle: String
    @Published var shareSectionTitle: String
    @Published var aboutSectionTitle: String
    @Published var versionSectionTitle: String
    @Published var tutorialOptionTitle: String
    @Published var languageSettingsOptionTitle: String
    @Published var loginOptionTitle: String
    @Published var createAccountOptionTitle: String
    @Published var activityOptionTitle: String
    @Published var logoutOptionTitle: String
    @Published var deleteAccountOptionTitle: String
    @Published var sendFeedbackOptionTitle: String
    @Published var reportABugOptionTitle: String
    @Published var askAQuestionOptionTitle: String
    @Published var leaveAReviewOptionTitle: String
    @Published var shareAStoryWithUsOptionTitle: String
    @Published var shareGodToolsOptionTitle: String
    @Published var termsOfUseOptionTitle: String
    @Published var privacyPolicyOptionTitle: String
    @Published var copyrightInfoOptionTitle: String
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        
        navTitle = localizationServices.stringForMainBundle(key: "settings")
        getStartedSectionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.SectionTitles.getStarted.rawValue)
        accountSectionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.SectionTitles.account.rawValue)
        supportSectionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.SectionTitles.support.rawValue)
        shareSectionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.SectionTitles.share.rawValue)
        aboutSectionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.SectionTitles.about.rawValue)
        versionSectionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.SectionTitles.version.rawValue)
        tutorialOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.tutorial.rawValue)
        languageSettingsOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.languageSettings.rawValue)
        loginOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.login.rawValue)
        createAccountOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.createAccount.rawValue)
        activityOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.activity.rawValue)
        logoutOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.logout.rawValue)
        deleteAccountOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.deleteAccount.rawValue)
        sendFeedbackOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.sendFeedback.rawValue)
        reportABugOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.reportABug.rawValue)
        askAQuestionOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.askAQuestion.rawValue)
        leaveAReviewOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.leaveAReview.rawValue)
        shareAStoryWithUsOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.shareAStoryWithUs.rawValue)
        shareGodToolsOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.shareGodTools.rawValue)
        termsOfUseOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.termsOfUse.rawValue)
        privacyPolicyOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.privacyPolicy.rawValue)
        copyrightInfoOptionTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.ItemTitles.copyrightInfo.rawValue)
        
    }
}

// MARK: - Inputs

extension MenuViewModel {
    
    @objc func doneTapped() {
        
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
}
