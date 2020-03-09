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
    private let deviceLanguage: DeviceLanguagePreferences
    private let tutorialServices: TutorialServicesType
    private let supportedLanguageCodesForAccountCreation: [String] = ["en"]
    
    private weak var flowDelegate: FlowDelegate?
    
    let loginClient: TheKeyOAuthClient
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.emptyData)
    
    required init(flowDelegate: FlowDelegate, loginClient: TheKeyOAuthClient, menuDataProvider: MenuDataProviderType, deviceLanguage: DeviceLanguagePreferences, tutorialServices: TutorialServicesType) {
        
        self.flowDelegate = flowDelegate
        self.loginClient = loginClient
        self.menuDataProvider = menuDataProvider
        self.deviceLanguage = deviceLanguage
        self.tutorialServices = tutorialServices
        
        super.init()
                
        reloadMenuDataSource()
    }
    
    func reloadMenuDataSource() {
        
        let accountCreationIsSupported: Bool = supportedLanguageCodesForAccountCreation.contains(deviceLanguage.languageCode ?? "unknown_code")
        
        menuDataSource.accept(value:
            createMenuDataSource(
                isAuthorized: loginClient.isAuthenticated(),
                accountCreationIsSupported: accountCreationIsSupported,
                deviceIsEnglish: deviceLanguage.isEnglish
            )
        )
    }
    
    private func createMenuDataSource(isAuthorized: Bool, accountCreationIsSupported: Bool, deviceIsEnglish: Bool) -> MenuDataSource {
        
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
                
                items = [
                    menuDataProvider.getMenuItem(id: .languageSettings),
                    menuDataProvider.getMenuItem(id: .tutorial),
                    menuDataProvider.getMenuItem(id: .about),
                    menuDataProvider.getMenuItem(id: .help),
                    menuDataProvider.getMenuItem(id: .contactUs)
                ]
                                
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
            
            items = items.filter {
                if !deviceIsEnglish {
                    return $0.id != .tutorial
                }
                else {
                    return true
                }
            }
            
            itemsDictionary[section.id] = items
        }
        
        return MenuDataSource(
            sections: sections,
            items: itemsDictionary
        )
    }
    
    func tutorialTapped() {
        tutorialServices.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .tutorialTappedFromMenu)
    }
    
    func myAccountTapped() {
        flowDelegate?.navigate(step: .myAccountTappedFromMenu)
    }
}
