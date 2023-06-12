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
    private let analytics: AnalyticsContainer
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase
    private let getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase
    private let logOutUserUseCase: LogOutUserUseCase
    private let getAppVersionUseCase: GetAppVersionUseCase
    private let authenticationCompletedSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
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
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase, getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, logOutUserUseCase: LogOutUserUseCase, getAppVersionUseCase: GetAppVersionUseCase) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAccountCreationIsSupportedUseCase = getAccountCreationIsSupportedUseCase
        self.getUserIsAuthenticatedUseCase = getUserIsAuthenticatedUseCase
        self.logOutUserUseCase = logOutUserUseCase
        self.getAppVersionUseCase = getAppVersionUseCase
        
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
                
        Publishers.CombineLatest(
            getAccountCreationIsSupportedUseCase.getIsSupportedPublisher(),
            getUserIsAuthenticatedUseCase.getIsAuthenticatedPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (accountCreation: AccountCreationIsSupportedDomainModel, userIsAuthenticated: Bool) in
            
            // TODO: Finish implementing and testing. See GT-2063 which should allow for observing userIsAuthenticated changes. ~Levi
            
            guard accountCreation.isSupported else {
                self?.accountSectionVisibility = .hidden
                return
            }
            
            self?.accountSectionVisibility = userIsAuthenticated ? .visibleLoggedIn : .visibleLoggedOut
        }
        .store(in: &cancellables)
        
        getAppVersionUseCase.getAppVersionPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appVersion: AppVersionDomainModel) in
                self?.appVersion = appVersion.versionString
            }
            .store(in: &cancellables)
    }
    
    private func getMenuAnalyticsScreenName () -> String {
        return "Menu"
    }
    
    private func getShareAppAnalyticsScreenName () -> String {
        return "Share App"
    }
    
    private func getShareStoryAnalyticsScreenName () -> String {
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
        
        let trackScreen = TrackScreenModel(
            screenName: getMenuAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
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
        flowDelegate?.navigate(step: .loginTappedFromMenu(authenticationCompletedSubject: authenticationCompletedSubject))
    }
    
    func activityTapped() {
        flowDelegate?.navigate(step: .activityTappedFromMenu)
    }
    
    func createAccountTapped() {
        flowDelegate?.navigate(step: .createAccountTappedFromMenu(authenticationCompletedSubject: authenticationCompletedSubject))
    }
    
    func logoutTapped() {
        
        logOutUserUseCase.logOutPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (finished: Bool) in
                
                // TODO: Menu should reflect changes after logging out. See GT-2063. ~Levi
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
        flowDelegate?.navigate(step: .leaveAReviewTappedFromMenu)
    }
    
    func shareAStoryWithUsTapped() {
        
        flowDelegate?.navigate(step: .shareAStoryWithUsTappedFromMenu)
        
        let trackScreen = TrackScreenModel(
            screenName: getShareStoryAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
    
    func shareGodToolsTapped() {
        
        flowDelegate?.navigate(step: .shareGodToolsTappedFromMenu)
        
        let trackAction = TrackActionModel(
            screenName: getShareAppAnalyticsScreenName(),
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [AnalyticsConstants.Keys.shareAction: 1]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
        
        let trackScreen = TrackScreenModel(
            screenName: getShareAppAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
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
