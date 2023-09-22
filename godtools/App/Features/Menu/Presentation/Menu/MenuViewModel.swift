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
    private let getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase
    private let getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase
    private let logOutUserUseCase: LogOutUserUseCase
    private let getAppVersionUseCase: GetAppVersionUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
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
    @Published var appVersion: String = ""
    @Published var accountSectionVisibility: MenuAccountSectionVisibility = .hidden
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase, getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, logOutUserUseCase: LogOutUserUseCase, getAppVersionUseCase: GetAppVersionUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAccountCreationIsSupportedUseCase = getAccountCreationIsSupportedUseCase
        self.getUserIsAuthenticatedUseCase = getUserIsAuthenticatedUseCase
        self.logOutUserUseCase = logOutUserUseCase
        self.getAppVersionUseCase = getAppVersionUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        navTitle = localizationServices.stringForSystemElseEnglish(key: "settings")
        getStartedSectionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SectionTitles.getStarted.rawValue)
        accountSectionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SectionTitles.account.rawValue)
        supportSectionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SectionTitles.support.rawValue)
        shareSectionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SectionTitles.share.rawValue)
        aboutSectionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SectionTitles.about.rawValue)
        versionSectionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SectionTitles.version.rawValue)
        tutorialOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.tutorial.rawValue)
        languageSettingsOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.languageSettings.rawValue)
        loginOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.login.rawValue)
        createAccountOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.createAccount.rawValue)
        activityOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.activity.rawValue)
        logoutOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.logout.rawValue)
        deleteAccountOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.deleteAccount.rawValue)
        sendFeedbackOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.sendFeedback.rawValue)
        reportABugOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.reportABug.rawValue)
        askAQuestionOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.askAQuestion.rawValue)
        leaveAReviewOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.leaveAReview.rawValue)
        shareAStoryWithUsOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.shareAStoryWithUs.rawValue)
        shareGodToolsOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.shareGodTools.rawValue)
        termsOfUseOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.termsOfUse.rawValue)
        privacyPolicyOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.privacyPolicy.rawValue)
        copyrightInfoOptionTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.ItemTitles.copyrightInfo.rawValue)
                
        Publishers.CombineLatest(
            getAccountCreationIsSupportedUseCase.getIsSupportedPublisher(),
            getUserIsAuthenticatedUseCase.getIsAuthenticatedPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (accountCreationIsSupportedDomainModel: AccountCreationIsSupportedDomainModel, userIsAuthenticatedDomainModel: UserIsAuthenticatedDomainModel) in
                        
            guard accountCreationIsSupportedDomainModel.isSupported else {
                self?.accountSectionVisibility = .hidden
                return
            }
            
            self?.accountSectionVisibility = userIsAuthenticatedDomainModel.isAuthenticated ? .visibleLoggedIn : .visibleLoggedOut
        }
        .store(in: &cancellables)
        
        getAppVersionUseCase.getAppVersionPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appVersion: AppVersionDomainModel) in
                self?.appVersion = appVersion.versionString
            }
            .store(in: &cancellables)
    }
    
    private func getMenuAnalyticsScreenName() -> String {
        return "Menu"
    }
    
    private func getShareAppAnalyticsScreenName() -> String {
        return "Share App"
    }
    
    private func getShareStoryAnalyticsScreenName() -> String {
        return "Share Story"
    }
    
    private var analyticsSiteSection: String {
        return "menu"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
}

// MARK: - Inputs

extension MenuViewModel {
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getMenuAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    @objc func doneTapped() {
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
    
    func tutorialTapped() {
        disableOptInOnboardingBannerUseCase.disableOptInOnboardingBanner()
        flowDelegate?.navigate(step: .tutorialTappedFromMenu)
    }
    
    func languageSettingsTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromMenu)
    }
    
    func loginTapped() {
        flowDelegate?.navigate(step: .loginTappedFromMenu)
    }
    
    func activityTapped() {
        flowDelegate?.navigate(step: .activityTappedFromMenu)
    }
    
    func createAccountTapped() {
        flowDelegate?.navigate(step: .createAccountTappedFromMenu)
    }
    
    func logoutTapped() {
        
        logOutUserUseCase.logOutPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { (finished: Bool) in
                
            })
            .store(in: &cancellables)
    }
    
    func deleteAccountTapped() {
        flowDelegate?.navigate(step: .deleteAccountTappedFromMenu)
    }
    
    func sendFeedbackTapped() {
        flowDelegate?.navigate(step: .sendFeedbackTappedFromMenu)
    }
    
    func reportABugTapped() {
        flowDelegate?.navigate(step: .reportABugTappedFromMenu)
    }
    
    func askAQuestionTapped() {
        flowDelegate?.navigate(step: .askAQuestionTappedFromMenu)
    }
    
    func leaveAReviewTapped() {
        
        flowDelegate?.navigate(step: .leaveAReviewTappedFromMenu(
            screenName: getMenuAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        ))
    }
    
    func shareAStoryWithUsTapped() {
        
        flowDelegate?.navigate(step: .shareAStoryWithUsTappedFromMenu)
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getShareStoryAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    func shareGodToolsTapped() {
        
        flowDelegate?.navigate(step: .shareGodToolsTappedFromMenu)
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: getShareAppAnalyticsScreenName(),
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.shareAction: 1]
        )
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getShareAppAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    func termsOfUseTapped() {
        flowDelegate?.navigate(step: .termsOfUseTappedFromMenu)
    }
    
    func privacyPolicyTapped() {
        flowDelegate?.navigate(step: .privacyPolicyTappedFromMenu)
    }
    
    func copyrightInfoTapped() {
        flowDelegate?.navigate(step: .copyrightInfoTappedFromMenu)
    }
}
