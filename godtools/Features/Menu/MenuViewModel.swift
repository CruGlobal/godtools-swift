//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift
import GTMAppAuth

class MenuViewModel: NSObject, MenuViewModelType {
    
    private let config: ConfigType
    private let menuDataProvider: MenuDataProviderType
    private let deviceLanguage: DeviceLanguageType
    private let tutorialAvailability: TutorialAvailabilityType
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let supportedLanguageCodesForAccountCreation: [String] = ["en"]
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let loginClient: TheKeyOAuthClient
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("settings", comment: ""))
    let navDoneButtonTitle: String = NSLocalizedString("done", comment: "")
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.emptyData)
    
    required init(flowDelegate: FlowDelegate, config: ConfigType, loginClient: TheKeyOAuthClient, menuDataProvider: MenuDataProviderType, deviceLanguage: DeviceLanguageType, tutorialAvailability: TutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.config = config
        self.loginClient = loginClient
        self.menuDataProvider = menuDataProvider
        self.deviceLanguage = deviceLanguage
        self.tutorialAvailability = tutorialAvailability
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.analytics = analytics
        
        super.init()
                
        reloadMenuDataSource()
    }
    
    func reloadMenuDataSource() {
        
        let accountCreationIsSupported: Bool = supportedLanguageCodesForAccountCreation.contains(deviceLanguage.languageCode ?? "unknown_code")
        
        menuDataSource.accept(value:
            createMenuDataSource(
                isAuthorized: loginClient.isAuthenticated(),
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
                
                items = [versionMenuItem]
            }
            
            itemsDictionary[section.id] = items
        }
        
        return MenuDataSource(
            sections: sections,
            items: itemsDictionary
        )
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Menu", siteSection: "", siteSubSection: "")
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
    
    func shareGodToolsTapped() {
        
        flowDelegate?.navigate(step: .shareGodToolsTappedFromMenu)
        
        analytics.trackActionAnalytics.trackAction(
            screenName: nil,
            actionName: AdobeAnalyticsConstants.Values.share,
            data: [AdobeAnalyticsConstants.Keys.shareAction: 1]
        )
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Share App", siteSection: "", siteSubSection: "")
    }
    
    func shareAStoryWithUsTapped() {
        
        flowDelegate?.navigate(step: .shareAStoryWithUsTappedFromMenu)
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Share Story", siteSection: "", siteSubSection: "")
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
