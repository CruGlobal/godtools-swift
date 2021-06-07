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
    private let menuDataProvider: MenuDataProviderType
    private let deviceLanguage: DeviceLanguageType
    private let tutorialAvailability: TutorialAvailabilityType
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let supportedLanguageCodesForAccountCreation: [String] = ["en"]
    private let userAuthentication: UserAuthenticationType
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let navDoneButtonTitle: String
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.emptyData)
    
    required init(flowDelegate: FlowDelegate, config: ConfigType, menuDataProvider: MenuDataProviderType, deviceLanguage: DeviceLanguageType, tutorialAvailability: TutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, userAuthentication: UserAuthenticationType, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.config = config
        self.menuDataProvider = menuDataProvider
        self.deviceLanguage = deviceLanguage
        self.tutorialAvailability = tutorialAvailability
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.userAuthentication = userAuthentication
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        navDoneButtonTitle = localizationServices.stringForMainBundle(key: "done")
        
        super.init()
        
        navTitle.accept(value: localizationServices.stringForMainBundle(key: "settings"))
                
        reloadMenuDataSource()
        
        setupBinding()
    }
    
    deinit {
        userAuthentication.didAuthenticateSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        userAuthentication.didAuthenticateSignal.addObserver(self) { [weak self] (result: Result<UserAuthModel, Error>) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadMenuDataSource()
            }
        }
    }
    
    func reloadMenuDataSource() {
        
        let accountCreationIsSupported: Bool = supportedLanguageCodesForAccountCreation.contains(deviceLanguage.languageCode ?? "unknown_code")
        
        menuDataSource.accept(value:
            createMenuDataSource(
                isAuthorized: userAuthentication.isAuthenticated,
                accountCreationIsSupported: accountCreationIsSupported,
                tutorialIsAvailable: tutorialAvailability.tutorialIsAvailable
            )
        )
    }
    
    private func createMenuDataSource(isAuthorized: Bool, accountCreationIsSupported: Bool, tutorialIsAvailable: Bool) -> MenuDataSource {
        
        var sections: [MenuSection] = Array()
        sections.append(menuDataProvider.getMenuSection(id: .general))
        if accountCreationIsSupported {
            sections.append(menuDataProvider.getMenuSection(id: .account))
        }
        sections.append(menuDataProvider.getMenuSection(id: .share))
        sections.append(menuDataProvider.getMenuSection(id: .legal))
        sections.append(menuDataProvider.getMenuSection(id: .version))
        
        var itemsDictionary: [MenuSectionId: [MenuItem]] = Dictionary()
        
        for section in sections {

            var items: [MenuItem] = Array()
            
            switch section.id {
                
            case .general:
                
                items.append(menuDataProvider.getMenuItem(id: .languageSettings))
                if tutorialIsAvailable {
                    items.append(menuDataProvider.getMenuItem(id: .tutorial))
                }
                items.append(menuDataProvider.getMenuItem(id: .about))
                items.append(menuDataProvider.getMenuItem(id: .help))
                items.append(menuDataProvider.getMenuItem(id: .contactUs))
                
            case .account:
                
                if isAuthorized {
                    items = [
                        menuDataProvider.getMenuItem(id: .myAccount),
                        menuDataProvider.getMenuItem(id: .logout)
                    ]
                }
                else {
                    items = [
                        menuDataProvider.getMenuItem(id: .createAccount),
                        menuDataProvider.getMenuItem(id: .login)
                    ]
                }
                
            case .share:
                items = [
                    menuDataProvider.getMenuItem(id: .shareGodTools),
                    menuDataProvider.getMenuItem(id: .shareAStoryWithUs)
                ]
            
            case .legal:
                items = [
                    menuDataProvider.getMenuItem(id: .termsOfUse),
                    menuDataProvider.getMenuItem(id: .privacyPolicy),
                    menuDataProvider.getMenuItem(id: .copyrightInfo)
                ]
                
            case .version:
                
                let versionMenuItem = MenuItem(
                    id: .version,
                    title: config.versionLabel
                )
                
                if config.isDebug {
                    items = [versionMenuItem, menuDataProvider.getMenuItem(id: .playground)]
                }
                else {
                    items = [versionMenuItem]
                }
            }
            
            itemsDictionary[section.id] = items
        }
        
        return MenuDataSource(
            sections: sections,
            items: itemsDictionary
        )
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: "Menu", siteSection: "", siteSubSection: "", url: nil))
    }
    
    func doneTapped() {
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
    
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
    
    func logoutTapped() {
        
        let loggedOutHandler: CallbackHandler = CallbackHandler { [weak self] in
            self?.userAuthentication.signOut()
            self?.reloadMenuDataSource()
            //on logout, sync Adobe Analytics auth state
            self?.analytics.adobeAnalytics.fetchAttributesThenSyncIds()
        }
        
        flowDelegate?.navigate(step: .logoutTappedFromMenu(logoutHandler: loggedOutHandler))
    }
    
    func loginTapped(fromViewController: UIViewController) {
        userAuthentication.signIn(fromViewController: fromViewController)
    }
    
    func createAccountTapped(fromViewController: UIViewController) {
        userAuthentication.createAccount(fromViewController: fromViewController)
    }
    
    func shareGodToolsTapped() {
        
        flowDelegate?.navigate(step: .shareGodToolsTappedFromMenu)
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: "Share App", actionName: AdobeAnalyticsConstants.Values.share, siteSection: "", siteSubSection: "", url: nil, data: [AdobeAnalyticsConstants.Keys.shareAction: 1]))
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: "Share App", siteSection: "", siteSubSection: "", url: nil))
    }
    
    func shareAStoryWithUsTapped() {
        
        flowDelegate?.navigate(step: .shareAStoryWithUsTappedFromMenu)
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: "Share Story", siteSection: "", siteSubSection: "", url: nil))
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
    
    func playgroundTapped() {
        flowDelegate?.navigate(step: .playgroundTappedFromMenu)
    }
}
