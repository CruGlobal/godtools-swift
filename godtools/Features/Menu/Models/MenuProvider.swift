//
//  MenuProvider.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MenuProvider: MenuProviderType {
        
    init() {
        
    }
    
    func getMenuDataSource(generalMenuSectionId: GeneralMenuSectionId) -> MenuDataSource {
        
        let sections = [
            MenuSection.create(id: .general(id: generalMenuSectionId)),
            MenuSection.create(id: .share),
            MenuSection.create(id: .legal)
        ]
        
        var itemsDictionary: [MenuSectionId: [MenuItem]] = Dictionary()
        
        for section in sections {
            itemsDictionary[section.id] = getMenuItems(id: section.id)
        }
        
        return MenuDataSource(sections: sections, items: itemsDictionary)
    }
    
    private func getMenuItems(id: MenuSectionId) -> [MenuItem] {
        
        switch id {
            
        case .general(let generalMenuSectionId):
            switch generalMenuSectionId {
                
            case .nonSupportedLanguage:
                return [
                    MenuItem.create(id: .languageSettings),
                    MenuItem.create(id: .about),
                    MenuItem.create(id: .help),
                    MenuItem.create(id: .contactUs)
                ]
                
            case .authorized:
                return [
                    MenuItem.create(id: .languageSettings),
                    MenuItem.create(id: .logout),
                    MenuItem.create(id: .about),
                    MenuItem.create(id: .help),
                    MenuItem.create(id: .contactUs)
                ]
                
            case .unauthorized:
                return [
                    MenuItem.create(id: .languageSettings),
                    MenuItem.create(id: .login),
                    MenuItem.create(id: .createAccount),
                    MenuItem.create(id: .about),
                    MenuItem.create(id: .help),
                    MenuItem.create(id: .contactUs)
                ]
            }
            
        case .share:
            return [
                MenuItem.create(id: .shareGodTools),
                MenuItem.create(id: .shareAStoryWithUs)
            ]
            
        case .legal:
            return [
                MenuItem.create(id: .termsOfUse),
                MenuItem.create(id: .privacyPolicy),
                MenuItem.create(id: .copyrightInfo)
            ]
        }
    }
}
