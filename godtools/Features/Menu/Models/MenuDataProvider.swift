//
//  MenuDataProvider.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MenuDataProvider: MenuDataProviderType {
     
    private let localizationServices: LocalizationServices
    
    required init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getMenuSection(id: MenuSectionId) -> MenuSection {
        
        switch id {
            
        case .general:
            return MenuSection(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu_general")
            )
            
        case .account:
            return MenuSection(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu_account")
            )
            
        case .share:
            return MenuSection(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu_share")
            )
            
        case .legal:
            return MenuSection(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu_legal")
            )
            
        case .version:
            return MenuSection(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu_version")
            )
        }
    }
    
    func getMenuItem(id: MenuItemId) -> MenuItem {
        
        switch id {
            
        case .languageSettings:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "language_settings")
            )
            
        case .about:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "about")
            )
            
        case .help:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "help")
            )
            
        case .contactUs:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "contact_us")
            )
            
        case .logout:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "logout")
            )
            
        case .login:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "login")
            )
            
        case .createAccount:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "create_account")
            )
            
        case .myAccount:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu.my_account")
            )
            
        case .shareGodTools:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "share_god_tools")
            )
            
        case .shareAStoryWithUs:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "share_a_story_with_us")
            )
            
        case .termsOfUse:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "terms_of_use")
            )
            
        case .privacyPolicy:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "privacy_policy")
            )
            
        case .copyrightInfo:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "copyright_info")
            )
            
        case .tutorial:
            return MenuItem(
                id: id,
                title: localizationServices.stringForMainBundle(key: "menu.tutorial")
            )
            
        case .version:
            return MenuItem(
                id: id,
                title: ""
            )
            
        case .playground:
            return MenuItem(
                id: .playground,
                title: "Playground"
            )
        }
    }
}
