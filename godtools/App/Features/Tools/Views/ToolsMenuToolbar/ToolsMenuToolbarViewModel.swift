//
//  ToolsMenuToolbarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolsMenuToolbarViewModel: ToolsMenuToolbarViewModelType {
        
    private let localizationServices: LocalizationServices
    
    required init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func learnToolbarItemWillAppear() -> ToolsMenuToolbarItemViewModelType {
        
        return ToolsMenuToolbarItemViewModel(
            title: localizationServices.stringForMainBundle(key: "tool_menu_item.lessons")
        )
    }
    
    func favoritedToolsToolbarItemWillAppear() -> ToolsMenuToolbarItemViewModelType {
        
        return ToolsMenuToolbarItemViewModel(
            title: localizationServices.stringForMainBundle(key: "my_tools")
        )
    }
    
    func allToolsToolbarItemWillAppear() -> ToolsMenuToolbarItemViewModelType {
        
        return ToolsMenuToolbarItemViewModel(
            title: localizationServices.stringForMainBundle(key: "find_tools")
        )
    }
}
