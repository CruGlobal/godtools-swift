//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class MenuViewModel: ObservableObject {
        
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
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
    
    @Published private(set) var hidesDebugSection: Bool = true
    @Published private(set) var navTitle: String = ""
    @Published private(set) var getStartedSectionTitle: String = ""
    @Published private(set) var accountSectionTitle: String = ""
    @Published private(set) var supportSectionTitle: String = ""
    @Published private(set) var shareSectionTitle: String = ""
    @Published private(set) var aboutSectionTitle: String = ""
    @Published private(set) var versionSectionTitle: String = ""
    @Published private(set) var tutorialOptionTitle: String = ""
    @Published private(set) var languageSettingsOptionTitle: String = ""
    @Published private(set) var localizationSettingsOptionTitle: String = ""
    @Published private(set) var loginOptionTitle: String = ""
    @Published private(set) var createAccountOptionTitle: String = ""
    @Published private(set) var activityOptionTitle: String = ""
    @Published private(set) var logoutOptionTitle: String = ""
    @Published private(set) var deleteAccountOptionTitle: String = ""
    @Published private(set) var sendFeedbackOptionTitle: String = ""
    @Published private(set) var reportABugOptionTitle: String = ""
    @Published private(set) var askAQuestionOptionTitle: String = ""
    @Published private(set) var leaveAReviewOptionTitle: String = ""
    @Published private(set) var shareAStoryWithUsOptionTitle: String = ""
    @Published private(set) var shareGodToolsOptionTitle: String = ""
    @Published private(set) var termsOfUseOptionTitle: String = ""
    @Published private(set) var privacyPolicyOptionTitle: String = ""
    @Published private(set) var copyrightInfoOptionTitle: String = ""
    @Published private(set) var appVersion: String = ""
    @Published private(set) var accountSectionVisibility: MenuAccountSectionVisibility = .hidden
    @Published private(set) var showsTutorialOption: Bool = false
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getMenuInterfaceStringsUseCase: GetMenuInterfaceStringsUseCase, getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase, getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, logOutUserUseCase: LogOutUserUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, appConfig: AppConfigInterface) {
        
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
        self.hidesDebugSection = !appConfig.isDebug
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getMenuInterfaceStringsUseCase
                    .getStringsPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
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
                self?.localizationSettingsOptionTitle = interfaceStrings.localizationSettingsOptionTitle
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
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                Publishers.CombineLatest(
                    getAccountCreationIsSupportedUseCase.getIsSupportedPublisher(appLanguage: appLanguage),
                    getUserIsAuthenticatedUseCase.getIsAuthenticatedPublisher()
                )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (accountCreationIsSupportedDomainModel: AccountCreationIsSupportedDomainModel, userIsAuthenticatedDomainModel: UserIsAuthenticatedDomainModel) in
                            
                if accountCreationIsSupportedDomainModel.isSupported {
                    
                    self?.accountSectionVisibility = userIsAuthenticatedDomainModel.isAuthenticated ? .visibleLoggedIn : .visibleLoggedOut
                }
                else {
                    
                    self?.accountSectionVisibility = .hidden
                }
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                
                getOptInOnboardingTutorialAvailableUseCase
                    .getIsAvailablePublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$showsTutorialOption)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    @objc func doneTapped() {
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
    
    func tutorialTapped() {
        disableOptInOnboardingBannerUseCase.execute()
        flowDelegate?.navigate(step: .tutorialTappedFromMenu)
    }
    
    func languageSettingsTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromMenu)
    }
    
    func localizationSettingsTapped() {
        flowDelegate?.navigate(step: .localizationSettingsTappedFromMenu)
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
            .store(in: &Self.backgroundCancellables)
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
            appLanguage: nil,
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
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.shareAction: 1]
        )
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getShareAppAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
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

// MARK: - Debug Inputs

extension MenuViewModel {
    
    func copyFirebaseDeviceTokenTapped() {
        flowDelegate?.navigate(step: .copyFirebaseDeviceTokenTappedFromMenu)
    }
}
