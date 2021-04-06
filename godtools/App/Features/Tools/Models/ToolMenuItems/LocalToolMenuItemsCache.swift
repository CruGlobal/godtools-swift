//
//  LocalToolMenuItemsCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LocalToolMenuItemsCache {
    
    private let localizationServices: LocalizationServices
    
    required init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getToolMenuItems() -> [ToolMenuItem] {
        
        let lessonsMenuItem = ToolMenuItem(id: .lessons, title: localizationServices.stringForMainBundle(key: "tool_menu_item.lessons"), accessibilityLabel: "lessons_tools")
        let favoritesMenuItem = ToolMenuItem(id: .favorites, title: localizationServices.stringForMainBundle(key: "my_tools"), accessibilityLabel: "my_tools")
        let allToolsMenuItem = ToolMenuItem(id: .allTools, title: localizationServices.stringForMainBundle(key: "find_tools"), accessibilityLabel: "find_tools")
        
        return [lessonsMenuItem, favoritesMenuItem, allToolsMenuItem]
    }
}
