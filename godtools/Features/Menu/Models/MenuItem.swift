//
//  MenuItem.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MenuItem {
    
    let id: MenuItemId
    let title: String
    
    static func create(id: MenuItemId) -> MenuItem {
        
        switch id {
            
        case .languageSettings:
            return MenuItem(
                id: id,
                title: NSLocalizedString("language_settings", comment: "")
            )
            
        case .about:
            return MenuItem(
                id: id,
                title: NSLocalizedString("about", comment: "")
            )
            
        case .help:
            return MenuItem(
                id: id,
                title: NSLocalizedString("help", comment: "")
            )
            
        case .contactUs:
            return MenuItem(
                id: id,
                title: NSLocalizedString("contact_us", comment: "")
            )
            
        case .logout:
            return MenuItem(
                id: id,
                title: NSLocalizedString("logout", comment: "")
            )
            
        case .login:
            return MenuItem(
                id: id,
                title: NSLocalizedString("login", comment: "")
            )
            
        case .createAccount:
            return MenuItem(
                id: id,
                title: NSLocalizedString("create_account", comment: "")
            )
            
        case .shareGodTools:
            return MenuItem(
                id: id,
                title: NSLocalizedString("share_god_tools", comment: "")
            )
            
        case .shareAStoryWithUs:
            return MenuItem(
                id: id,
                title: NSLocalizedString("share_a_story_with_us", comment: "")
            )
            
        case .termsOfUse:
            return MenuItem(
                id: id,
                title: NSLocalizedString("terms_of_use", comment: "")
            )
            
        case .privacyPolicy:
            return MenuItem(
                id: id,
                title: NSLocalizedString("privacy_policy", comment: "")
            )
            
        case .copyrightInfo:
            return MenuItem(
                id: id,
                title: NSLocalizedString("copyright_info", comment: "")
            )
        }
    }
}
