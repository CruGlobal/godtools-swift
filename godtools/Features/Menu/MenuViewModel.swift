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
    
    private let menuDataProvider: MenuDataProviderType
    private let deviceLanguage: DeviceLanguageType
    private let tutorialAvailability: TutorialAvailabilityType
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let supportedLanguageCodesForAccountCreation: [String] = ["en"]
    
    private weak var flowDelegate: FlowDelegate?
    
    let loginClient: TheKeyOAuthClient
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.emptyData)
    
    required init(flowDelegate: FlowDelegate, loginClient: TheKeyOAuthClient, menuDataProvider: MenuDataProviderType, deviceLanguage: DeviceLanguageType, tutorialAvailability: TutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType) {
        
        self.flowDelegate = flowDelegate
        self.loginClient = loginClient
        self.menuDataProvider = menuDataProvider
        self.deviceLanguage = deviceLanguage
        self.tutorialAvailability = tutorialAvailability
        self.openTutorialCalloutCache = openTutorialCalloutCache
        
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
            }
            
            itemsDictionary[section.id] = items
        }
        
        return MenuDataSource(
            sections: sections,
            items: itemsDictionary
        )
    }
    
    func tutorialTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .tutorialTappedFromMenu)
    }
    
    func myAccountTapped() {
        flowDelegate?.navigate(step: .myAccountTappedFromMenu)
    }
}
