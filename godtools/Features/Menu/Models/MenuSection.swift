//
//  MenuSection.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MenuSection {
    
    let id: MenuSectionId
    let title: String
    
    static func create(id: MenuSectionId) -> MenuSection {
        
        switch id {
            
        case .general(let generalMenuSectionId):
            
            let generalTitle: String = NSLocalizedString("menu_general", comment: "")
            
            switch generalMenuSectionId {
            case .nonSupportedLanguage:
                return MenuSection(
                    id: id,
                    title: generalTitle
                )
                
            case .authorized:
                return MenuSection(
                    id: id,
                    title: generalTitle
                )
                
            case .unauthorized:
                return MenuSection(
                    id: id,
                    title: generalTitle
                )
            }
            
        case .share:
            return MenuSection(
                id: id,
                title: NSLocalizedString("menu_share", comment: "")
            )
            
        case .legal:
            return MenuSection(
                id: id,
                title: NSLocalizedString("menu_legal", comment: "")
            )
        }
    }
}
