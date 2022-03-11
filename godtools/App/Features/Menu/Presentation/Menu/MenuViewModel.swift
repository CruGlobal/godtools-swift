//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MenuViewModel: NSObject, MenuViewModelType {
    
    private let config: ConfigType
    private let deviceLanguage: DeviceLanguageType
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let supportedLanguageCodesForAccountCreation: [String] = ["en"]
    private let userAuthentication: UserAuthenticationType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let navDoneButtonTitle: String
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.createEmptyDataSource())
    
    required init(flowDelegate: FlowDelegate, config: ConfigType, deviceLanguage: DeviceLanguageType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, userAuthentication: UserAuthenticationType, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase) {
        
        self.flowDelegate = flowDelegate
        self.config = config
        self.deviceLanguage = deviceLanguage
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.userAuthentication = userAuthentication
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        
        navDoneButtonTitle = localizationServices.stringForMainBundle(key: "done")
        
        super.init()
        
        navTitle.accept(value: localizationServices.stringForMainBundle(key: "settings"))
                
        reloadMenuDataSource()
        
        setupBinding()
    }
    
    deinit {
        userAuthentication.didAuthenticateSignal.removeObserver(self)
        userAuthentication.didSignOutSignal.removeObserver(self)
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
    
    private func setupBinding() {
        
        userAuthentication.didAuthenticateSignal.addObserver(self) { [weak self] (result: Result<AuthUserModelType, Error>) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadMenuDataSource()
            }
        }
        
        userAuthentication.didSignOutSignal.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadMenuDataSource()
            }
        }
    }
    
    private func reloadMenuDataSource() {
        
        let isAuthorized: Bool = userAuthentication.isAuthenticated
        let accountCreationIsSupported: Bool = supportedLanguageCodesForAccountCreation.contains(deviceLanguage.languageCode ?? "unknown_code")
        let tutorialIsAvailable: Bool = getTutorialIsAvailableUseCase.getTutorialIsAvailable()
        
        var sections: [MenuSection] = Array()
        sections.append(.general)
        if accountCreationIsSupported {
            sections.append(.account)
        }
        sections.append(.share)
        sections.append(.legal)
        sections.append(.version)
        
        var itemsDictionary: [MenuSection: [MenuItem]] = Dictionary()
        
        for section in sections {

            var items: [MenuItem] = Array()
            
            switch section {
                
            case .general:
                
                items.append(.languageSettings)
                if tutorialIsAvailable {
                    items.append(.tutorial)
                }
                items.append(.about)
                items.append(.help)
                items.append(.contactUs)
                
            case .account:
                
                if isAuthorized {
                    items = [.myAccount, .logout]
                }
                else {
                    items = [.createAccount, .login]
                }
                
            case .share:
                
                items = [.shareGodTools, .shareAStoryWithUs]
            
            case .legal:
                
                items = [.termsOfUse, .privacyPolicy, .copyrightInfo]
                
            case .version:
                
                items = [.version]
            }
            
            itemsDictionary[section] = items
        }
        
        let menuDataSourceValue: MenuDataSource = MenuDataSource(sections: sections, items: itemsDictionary)
        
        menuDataSource.accept(value: menuDataSourceValue)
    }

    func menuSectionWillAppear(sectionIndex: Int) -> MenuSectionHeaderViewModelType {
        
        let menuSection: MenuSection = menuDataSource.value.sections[sectionIndex]
        let sectionTitle: String = getSectionTitle(section: menuSection)
        
        return MenuSectionHeaderViewModel(headerTitle: sectionTitle)
    }
    
    func menuItemWillAppear(sectionIndex: Int, itemIndexRelativeToSection: Int) -> MenuItemViewModelType {
        
        let menuDataSource: MenuDataSource = menuDataSource.value
        let menuItem: MenuItem = menuDataSource.getMenuItem(at: IndexPath(row: itemIndexRelativeToSection, section: sectionIndex))
        let itemTitle: String = getItemTitle(item: menuItem)
        
        let selectionDisabled: Bool = menuItem == .version
        
        return MenuItemViewModel(title: itemTitle, selectionDisabled: selectionDisabled)
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getMenuAnalyticsScreenName(), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func doneTapped() {
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
}

// MARK: - Menu Option Tapped

extension MenuViewModel {
    
    func languageSettingsTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromMenu)
    }
    
    func tutorialTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .tutorialTappedFromMenu)
    }
    
    func myAccountTapped() {
        flowDelegate?.navigate(step: .myAccountTappedFromMenu)
    }
    
    func aboutTapped() {
        flowDelegate?.navigate(step: .aboutTappedFromMenu)
    }
    
    func helpTapped() {
        flowDelegate?.navigate(step: .helpTappedFromMenu)
    }
    
    func contactUsTapped() {
        flowDelegate?.navigate(step: .contactUsTappedFromMenu)
    }
    
    func logoutTapped(fromViewController: UIViewController) {
        userAuthentication.signOut(fromViewController: fromViewController)
    }
    
    func loginTapped(fromViewController: UIViewController) {
        userAuthentication.authenticate(fromViewController: fromViewController)
    }
    
    func createAccountTapped(fromViewController: UIViewController) {
        userAuthentication.authenticate(fromViewController: fromViewController)
    }
    
    func shareGodToolsTapped() {
        
        flowDelegate?.navigate(step: .shareGodToolsTappedFromMenu)
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: getShareAppAnalyticsScreenName(), actionName: AnalyticsConstants.ActionNames.shareIconEngaged, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection, url: nil, data: [AnalyticsConstants.Keys.shareAction: 1]))
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getShareAppAnalyticsScreenName(), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func shareAStoryWithUsTapped() {
        
        flowDelegate?.navigate(step: .shareAStoryWithUsTappedFromMenu)
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getShareStoryAnalyticsScreenName(), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
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

extension MenuViewModel {
    
    private func getSectionTitle(section: MenuSection) -> String {
        
        let localizedKey: String
        
        switch section {
            
        case .general:
            localizedKey = "menu_general"
            
        case .account:
            localizedKey = "menu_account"
            
        case .share:
            localizedKey = "menu_share"
            
        case .legal:
            localizedKey = "menu_legal"
            
        case .version:
            localizedKey = "menu_version"
        }
        
        return localizationServices.stringForMainBundle(key: localizedKey)
    }
    
    private func getItemTitle(item: MenuItem) -> String {
        
        let localizedKey: String
        
        switch item {
            
        case .languageSettings:
            localizedKey = "language_settings"
            
        case .about:
            localizedKey = "about"
            
        case .help:
            localizedKey = "help"
            
        case .contactUs:
            localizedKey = "contact_us"
            
        case .logout:
            localizedKey = "logout"
            
        case .login:
            localizedKey = "login"
            
        case .createAccount:
            localizedKey = "create_account"
            
        case .myAccount:
            localizedKey = "menu.my_account"
            
        case .shareGodTools:
            localizedKey = "share_god_tools"
            
        case .shareAStoryWithUs:
            localizedKey = "share_a_story_with_us"
            
        case .termsOfUse:
            localizedKey = "terms_of_use"
            
        case .privacyPolicy:
            localizedKey = "privacy_policy"
            
        case .copyrightInfo:
            localizedKey = "copyright_info"
            
        case .tutorial:
            localizedKey = "menu.tutorial"
            
        case .version:
            return "v" + config.appVersion + " " + "(" + config.bundleVersion + ")"
        }
        
        return localizationServices.stringForMainBundle(key: localizedKey)
    }
}
