//
//  ToolsMenuToolbarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolsMenuToolbarViewModel: ToolsMenuToolbarViewModelType {
    
    private let toolMenuItemsRepository: ToolMenuItemsRepository
    
    private var toolbarItems: [ToolMenuItem] = Array()
    
    let numberOfToolbarItems: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(toolMenuItemsRepository: ToolMenuItemsRepository) {
        
        self.toolMenuItemsRepository = toolMenuItemsRepository
        
        toolMenuItemsRepository.getToolMenuItems { [weak self] (toolMenuItems: [ToolMenuItem]) in
            self?.reloadToolbarItems(toolbarItems: toolMenuItems)
        }
    }
    
    private func reloadToolbarItems(toolbarItems: [ToolMenuItem]) {
        self.toolbarItems = toolbarItems
        numberOfToolbarItems.accept(value: toolbarItems.count)
    }
    
    func toolbarItemWillAppear(index: Int) -> ToolsMenuToolbarItemViewModelType {
        
        let toolMenuItem: ToolMenuItem = toolbarItems[index]
        
        return ToolsMenuToolbarItemViewModel(toolMenuItem: toolMenuItem)
    }
}
