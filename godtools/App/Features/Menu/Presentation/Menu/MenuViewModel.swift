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
    private let getMenuStringsUseCase: GetMenuStringsUseCase
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
    
    @Published private(set) var strings = MenuStringsDomainModel.emptyValue
    @Published private(set) var hidesDebugSection: Bool = true
    @Published private(set) var accountSectionVisibility: MenuAccountSectionVisibility = .hidden
    @Published private(set) var showsTutorialOption: Bool = false
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getMenuStringsUseCase: GetMenuStringsUseCase, getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase, getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, logOutUserUseCase: LogOutUserUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, appConfig: AppConfigInterface) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getMenuStringsUseCase = getMenuStringsUseCase
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAccountCreationIsSupportedUseCase = getAccountCreationIsSupportedUseCase
        self.getUserIsAuthenticatedUseCase = getUserIsAuthenticatedUseCase
        self.logOutUserUseCase = logOutUserUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.hidesDebugSection = !appConfig.isDebug
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getMenuStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: MenuStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                Publishers.CombineLatest(
                    getAccountCreationIsSupportedUseCase
                        .execute(appLanguage: appLanguage),
                    getUserIsAuthenticatedUseCase
                        .execute()
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
        
        logOutUserUseCase
            .execute()
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
