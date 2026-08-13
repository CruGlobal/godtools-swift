//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class MenuViewModel: ObservableObject {
            
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getMenuStringsUseCase: GetMenuStringsUseCase
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase
    private let getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase
    private let logOutUserUseCase: LogOutUserUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = MenuStringsDomainModel.emptyValue
    @Published private(set) var hidesDebugSection: Bool = true
    @Published private(set) var accountSectionVisibility: MenuAccountSectionVisibility = .hidden
    @Published private(set) var showsTutorialOption: Bool = false
    
    init(
        stepEmitter: FlowStepEmitter,
        appLanguage: AppLanguageDomainModel,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getMenuStringsUseCase: GetMenuStringsUseCase,
        getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase,
        disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase,
        getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase,
        getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase,
        logOutUserUseCase: LogOutUserUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        appBuild: AppBuildInterface
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getMenuStringsUseCase = getMenuStringsUseCase
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAccountCreationIsSupportedUseCase = getAccountCreationIsSupportedUseCase
        self.getUserIsAuthenticatedUseCase = getUserIsAuthenticatedUseCase
        self.logOutUserUseCase = logOutUserUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.hidesDebugSection = !appBuild.isDebug
        
        didSetAppLanguage(appLanguage: appLanguage)
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                Publishers.CombineLatest(
                    AnyPublisher() {
                        await getAccountCreationIsSupportedUseCase
                            .execute(appLanguage: appLanguage)
                    },
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
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            strings = await getMenuStringsUseCase
                .execute(appLanguage: appLanguage)

            showsTutorialOption = getTutorialIsAvailableUseCase
                .execute(appLanguage: appLanguage)
        }
    }
}

// MARK: - Inputs

extension MenuViewModel {
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            properties: AnalyticsProperties(
                screenName: getMenuAnalyticsScreenName(),
                siteSection: analyticsSiteSection,
                siteSubSection: analyticsSiteSubSection,
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        )
    }
    
    @objc func doneTapped() {
        stepEmitter.emit(step: AppFlowStep.doneTappedFromMenu)
    }
    
    func tutorialTapped() {
        disableOptInOnboardingBannerUseCase.execute()
        stepEmitter.emit(step: AppFlowStep.tutorialTappedFromMenu)
    }
    
    func languageSettingsTapped() {
        stepEmitter.emit(step: AppFlowStep.languageSettingsTappedFromMenu)
    }
    
    func localizationSettingsTapped() {
        stepEmitter.emit(step: AppFlowStep.localizationSettingsTappedFromMenu)
    }
    
    func loginTapped() {
        stepEmitter.emit(step: AppFlowStep.loginTappedFromMenu)
    }
    
    func activityTapped() {
        stepEmitter.emit(step: AppFlowStep.activityTappedFromMenu)
    }
    
    func createAccountTapped() {
        stepEmitter.emit(step: AppFlowStep.createAccountTappedFromMenu)
    }
    
    func logoutTapped() {
        
        Task {
            _ = try await logOutUserUseCase
                .execute()
        }
    }
    
    func deleteAccountTapped() {
        stepEmitter.emit(step: AppFlowStep.deleteAccountTappedFromMenu)
    }
    
    func sendFeedbackTapped() {
        stepEmitter.emit(step: AppFlowStep.sendFeedbackTappedFromMenu)
    }
    
    func reportABugTapped() {
        stepEmitter.emit(step: AppFlowStep.reportABugTappedFromMenu)
    }
    
    func askAQuestionTapped() {
        stepEmitter.emit(step: AppFlowStep.askAQuestionTappedFromMenu)
    }
    
    func leaveAReviewTapped() {
        
        stepEmitter.emit(step: AppFlowStep.leaveAReviewTappedFromMenu(
            screenName: getMenuAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        ))
    }
    
    func shareAStoryWithUsTapped() {
        
        stepEmitter.emit(step: AppFlowStep.shareAStoryWithUsTappedFromMenu)
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            properties: AnalyticsProperties(
                screenName: getShareStoryAnalyticsScreenName(),
                siteSection: analyticsSiteSection,
                siteSubSection: analyticsSiteSubSection,
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        )
    }
    
    func shareGodToolsTapped() {
        
        stepEmitter.emit(step: AppFlowStep.shareGodToolsTappedFromMenu)
        
        trackActionAnalyticsUseCase.trackAction(
            properties: AnalyticsProperties(
                screenName: getShareAppAnalyticsScreenName(),
                siteSection: analyticsSiteSection,
                siteSubSection: analyticsSiteSubSection,
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            ),
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            data: [AnalyticsConstants.Keys.shareAction: 1]
        )
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            properties: AnalyticsProperties(
                screenName: getShareAppAnalyticsScreenName(),
                siteSection: analyticsSiteSection,
                siteSubSection: analyticsSiteSubSection,
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        )
    }
    
    func termsOfUseTapped() {
        stepEmitter.emit(step: AppFlowStep.termsOfUseTappedFromMenu)
    }
    
    func privacyPolicyTapped() {
        stepEmitter.emit(step: AppFlowStep.privacyPolicyTappedFromMenu)
    }
    
    func copyrightInfoTapped() {
        stepEmitter.emit(step: AppFlowStep.copyrightInfoTappedFromMenu)
    }
}

// MARK: - Debug Inputs

extension MenuViewModel {
    
    func copyFirebaseDeviceTokenTapped() {
        stepEmitter.emit(step: AppFlowStep.copyFirebaseDeviceTokenTappedFromMenu)
    }
}
