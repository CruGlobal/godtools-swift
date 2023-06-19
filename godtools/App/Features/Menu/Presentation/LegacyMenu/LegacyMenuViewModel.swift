//
//  LegacyMenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Combine

class LegacyMenuViewModel {
    
    private let infoPlist: InfoPlist
    private let getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase
    private let logOutUserUseCase: LogOutUserUseCase
    private let getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let navDoneButtonTitle: String
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.createEmptyDataSource())
    
    init(flowDelegate: FlowDelegate, infoPlist: InfoPlist, getAccountCreationIsSupportedUseCase: GetAccountCreationIsSupportedUseCase, logOutUserUseCase: LogOutUserUseCase, getUserIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase) {
        
        self.flowDelegate = flowDelegate
        self.infoPlist = infoPlist
        self.getAccountCreationIsSupportedUseCase = getAccountCreationIsSupportedUseCase
        self.logOutUserUseCase = logOutUserUseCase
        self.getUserIsAuthenticatedUseCase = getUserIsAuthenticatedUseCase
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        
        navDoneButtonTitle = localizationServices.stringForMainBundle(key: "done")
                
        navTitle.accept(value: localizationServices.stringForMainBundle(key: "settings"))
                
        reloadMenuDataSource()
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
    
    private func reloadMenuDataSource() {
        
        // TODO: Disabling as we move to new MenuViewModel. ~Levi
        //let isAuthorized: Bool = getUserIsAuthenticatedUseCase.getUserIsAuthenticated()
        let isAuthorized: Bool = false
        
        // TODO: Disabling as we move to new MenuViewModel. ~Levi
        //let accountCreationIsSupported: Bool = getAccountCreationIsSupportedUseCase.getAccountCreationIsSupported().isSupported
        let accountCreationIsSupported: Bool = false
        
        let tutorialIsAvailable: Bool = getOptInOnboardingTutorialAvailableUseCase.getOptInOnboardingTutorialIsAvailable()
        
        var sections: [MenuSection] = Array()
        sections.append(.getStarted)
        if accountCreationIsSupported {
            sections.append(.account)
        }
        sections.append(.support)
        sections.append(.share)
        sections.append(.about)
        sections.append(.version)
        
        var itemsDictionary: [MenuSection: [MenuItem]] = Dictionary()
        
        for section in sections {

            var items: [MenuItem] = Array()
            
            switch section {
                
            case .getStarted:
                
                if tutorialIsAvailable {
                    items.append(.tutorial)
                }
                items.append(.languageSettings)
                
            case .account:
                
                if isAuthorized {
                    items = [.activity, .logout, .deleteAccount]
                }
                else {
                    items = [.login, .createAccount]
                }
                
            case .support:
                
                items = [.sendFeedback, .reportABug, .askAQuestion]
                
            case .share:
                
                items = [.leaveAReview, .shareAStoryWithUs, .shareGodTools]
            
            case .about:
                
                items = [.termsOfUse, .privacyPolicy, .copyrightInfo]
                
            case .version:
                
                items = [.version]
            }
            
            itemsDictionary[section] = items
        }
        
        let menuDataSourceValue: MenuDataSource = MenuDataSource(sections: sections, items: itemsDictionary)
        
        menuDataSource.accept(value: menuDataSourceValue)
    }
    
    private func getSectionTitle(section: MenuSection) -> String {
        
        let localizedKey: String
        
        switch section {
            
        case .getStarted:
            localizedKey = MenuStringKeys.SectionTitles.getStarted.rawValue
            
        case .account:
            localizedKey = MenuStringKeys.SectionTitles.account.rawValue
            
        case .support:
            localizedKey = MenuStringKeys.SectionTitles.support.rawValue
            
        case .share:
            localizedKey = MenuStringKeys.SectionTitles.share.rawValue
            
        case .about:
            localizedKey = MenuStringKeys.SectionTitles.about.rawValue
            
        case .version:
            localizedKey = MenuStringKeys.SectionTitles.version.rawValue
        }
        
        return localizationServices.stringForMainBundle(key: localizedKey)
    }
    
    private func getItemTitle(item: MenuItem) -> String {
        
        let localizedKey: String
        
        switch item {
            
        case .tutorial:
            localizedKey = MenuStringKeys.ItemTitles.tutorial.rawValue
            
        case .languageSettings:
            localizedKey = MenuStringKeys.ItemTitles.languageSettings.rawValue
            
        case .login:
            localizedKey = MenuStringKeys.ItemTitles.login.rawValue
            
        case .activity:
            localizedKey = MenuStringKeys.ItemTitles.activity.rawValue
            
        case .createAccount:
            localizedKey = MenuStringKeys.ItemTitles.createAccount.rawValue
            
        case .logout:
            localizedKey = MenuStringKeys.ItemTitles.logout.rawValue
            
        case .deleteAccount:
            localizedKey = MenuStringKeys.ItemTitles.deleteAccount.rawValue
            
        case .sendFeedback:
            localizedKey = MenuStringKeys.ItemTitles.sendFeedback.rawValue
            
        case .reportABug:
            localizedKey = MenuStringKeys.ItemTitles.reportABug.rawValue
            
        case .askAQuestion:
            localizedKey = MenuStringKeys.ItemTitles.askAQuestion.rawValue
            
        case .leaveAReview:
            localizedKey = MenuStringKeys.ItemTitles.leaveAReview.rawValue
            
        case .shareAStoryWithUs:
            localizedKey = MenuStringKeys.ItemTitles.shareAStoryWithUs.rawValue
        
        case .shareGodTools:
            localizedKey = MenuStringKeys.ItemTitles.shareGodTools.rawValue
            
        case .termsOfUse:
            localizedKey = MenuStringKeys.ItemTitles.termsOfUse.rawValue
            
        case .privacyPolicy:
            localizedKey = MenuStringKeys.ItemTitles.privacyPolicy.rawValue
            
        case .copyrightInfo:
            localizedKey = MenuStringKeys.ItemTitles.copyrightInfo.rawValue
            
        case .version:
            
            if let appVersion = infoPlist.appVersion, let bundleVersion = infoPlist.bundleVersion {
                return "v" + appVersion + " " + "(" + bundleVersion + ")"
            }
            
            return ""
        }
        
        return localizationServices.stringForMainBundle(key: localizedKey)
    }
}

// MARK: - Inputs

extension LegacyMenuViewModel {
    
    func menuSectionWillAppear(sectionIndex: Int) -> LegacyMenuSectionHeaderViewModel {
        
        let menuSection: MenuSection = menuDataSource.value.sections[sectionIndex]
        let sectionTitle: String = getSectionTitle(section: menuSection)
        
        return LegacyMenuSectionHeaderViewModel(headerTitle: sectionTitle)
    }
    
    func menuItemWillAppear(sectionIndex: Int, itemIndexRelativeToSection: Int) -> LegacyMenuItemViewModel {
        
        let menuDataSource: MenuDataSource = menuDataSource.value
        let menuItem: MenuItem = menuDataSource.getMenuItem(at: IndexPath(row: itemIndexRelativeToSection, section: sectionIndex))
        let itemTitle: String = getItemTitle(item: menuItem)
        
        let selectionDisabled: Bool = menuItem == .version
        
        return LegacyMenuItemViewModel(title: itemTitle, selectionDisabled: selectionDisabled)
    }
    
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
    
    func doneTapped() {
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
    
    func tutorialTapped() {
        disableOptInOnboardingBannerUseCase.disableOptInOnboardingBanner()
        flowDelegate?.navigate(step: .tutorialTappedFromMenu)
    }
    
    func languageSettingsTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromMenu)
    }
    
    func loginTapped(fromViewController: UIViewController) {
        flowDelegate?.navigate(step: .loginTappedFromMenu)
    }
    
    func activityTapped() {
        flowDelegate?.navigate(step: .activityTappedFromMenu)
    }
    
    func createAccountTapped(fromViewController: UIViewController) {
        flowDelegate?.navigate(step: .createAccountTappedFromMenu)
    }
    
    func logoutTapped(fromViewController: UIViewController) {
        
        logOutUserUseCase.logOutPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (finished: Bool) in
                self?.reloadMenuDataSource()
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
