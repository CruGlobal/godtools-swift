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
        
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getMenuInterfaceStringsUseCase: GetMenuInterfaceStringsUseCase
    private let getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase
    private let getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase
    private let logOutUserUseCase: LogOutUserUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var navTitle: String = ""
    @Published var getStartedSectionTitle: String = ""
    @Published var accountSectionTitle: String = ""
    @Published var supportSectionTitle: String = ""
    @Published var shareSectionTitle: String = ""
    @Published var aboutSectionTitle: String = ""
    @Published var versionSectionTitle: String = ""
    @Published var tutorialOptionTitle: String = ""
    @Published var languageSettingsOptionTitle: String = ""
    @Published var loginOptionTitle: String = ""
    @Published var createAccountOptionTitle: String = ""
    @Published var activityOptionTitle: String = ""
    @Published var logoutOptionTitle: String = ""
    @Published var deleteAccountOptionTitle: String = ""
    @Published var sendFeedbackOptionTitle: String = ""
    @Published var reportABugOptionTitle: String = ""
    @Published var askAQuestionOptionTitle: String = ""
    @Published var leaveAReviewOptionTitle: String = ""
    @Published var shareAStoryWithUsOptionTitle: String = ""
    @Published var shareGodToolsOptionTitle: String = ""
    @Published var termsOfUseOptionTitle: String = ""
    @Published var privacyPolicyOptionTitle: String = ""
    @Published var copyrightInfoOptionTitle: String = ""
    @Published var appVersion: String = ""
    @Published var accountSectionVisibility: MenuAccountSectionVisibility = .hidden
    @Published var showsTutorialOption: Bool = false
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getMenuInterfaceStringsUseCase: GetMenuInterfaceStringsUseCase, getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase, getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, logOutUserUseCase: LogOutUserUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getMenuInterfaceStringsUseCase = getMenuInterfaceStringsUseCase
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAccountCreationIsSupportedUseCase = getAccountCreationIsSupportedUseCase
        self.getUserIsAuthenticatedUseCase = getUserIsAuthenticatedUseCase
        self.logOutUserUseCase = logOutUserUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        getMenuInterfaceStringsUseCase
            .getStringsPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: MenuInterfaceStringsDomainModel) in
                
                self?.navTitle = interfaceStrings.title
                self?.getStartedSectionTitle = interfaceStrings.getStartedTitle
                self?.accountSectionTitle = interfaceStrings.accountTitle
                self?.supportSectionTitle = interfaceStrings.supportTitle
                self?.shareSectionTitle = interfaceStrings.shareTitle
                self?.aboutSectionTitle = interfaceStrings.aboutTitle
                self?.versionSectionTitle = interfaceStrings.versionTitle
                self?.tutorialOptionTitle = interfaceStrings.tutorialOptionTitle
                self?.languageSettingsOptionTitle = interfaceStrings.languageSettingsOptionTitle
                self?.loginOptionTitle = interfaceStrings.loginOptionTitle
                self?.createAccountOptionTitle = interfaceStrings.createAccountOptionTitle
                self?.activityOptionTitle = interfaceStrings.activityOptionTitle
                self?.logoutOptionTitle = interfaceStrings.logoutOptionTitle
                self?.deleteAccountOptionTitle = interfaceStrings.deleteAccountOptionTitle
                self?.sendFeedbackOptionTitle = interfaceStrings.sendFeedbackOptionTitle
                self?.reportABugOptionTitle = interfaceStrings.reportABugOptionTitle
                self?.askAQuestionOptionTitle = interfaceStrings.askAQuestionOptionTitle
                self?.leaveAReviewOptionTitle = interfaceStrings.leaveAReviewOptionTitle
                self?.shareAStoryWithUsOptionTitle = interfaceStrings.shareAStoryWithUsOptionTitle
                self?.shareGodToolsOptionTitle = interfaceStrings.shareGodToolsOptionTitle
                self?.termsOfUseOptionTitle = interfaceStrings.termsOfUseOptionTitle
                self?.privacyPolicyOptionTitle = interfaceStrings.privacyPolicyOptionTitle
                self?.copyrightInfoOptionTitle = interfaceStrings.copyrightInfoOptionTitle
                self?.appVersion = interfaceStrings.version
            }
            .store(in: &cancellables)
                        
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
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ appLanguage -> AnyPublisher<Bool, Never> in
                return self.getOptInOnboardingTutorialAvailableUseCase
                    .getIsAvailablePublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$showsTutorialOption)
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
