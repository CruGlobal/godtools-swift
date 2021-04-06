//
//  ToolsMenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolsMenuViewModel: ToolsMenuViewModelType {
    
    private let toolMenuItemsRepository: ToolMenuItemsRepository
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    let favoritesMenuItem: ToolMenuItem
    let allToolsMenuItem: ToolMenuItem
    let toolMenuItems: ObservableValue<[ToolMenuItem]> = ObservableValue(value: [])
    let selectedToolMenuItem: ObservableValue<ToolMenuItem?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, toolMenuItemsRepository: ToolMenuItemsRepository, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.toolMenuItemsRepository = toolMenuItemsRepository
        self.localizationServices = localizationServices
        
        favoritesMenuItem = ToolMenuItem(id: .favorites, title: localizationServices.stringForMainBundle(key: "my_tools"), accessibilityLabel: "my_tools")
        allToolsMenuItem = ToolMenuItem(id: .allTools, title: localizationServices.stringForMainBundle(key: "find_tools"), accessibilityLabel: "find_tools")
        
        reloadToolMenu()
    }
    
    private func reloadToolMenu() {
        toolMenuItems.accept(value: [favoritesMenuItem, allToolsMenuItem])
        selectedToolMenuItem.accept(value: favoritesMenuItem)
    }
    
    func toolbarWillAppear() -> ToolsMenuToolbarViewModelType {
        return ToolsMenuToolbarViewModel(toolMenuItemsRepository: toolMenuItemsRepository)
    }
    
    func resetMenu() {
        selectedToolMenuItem.accept(value: favoritesMenuItem)
    }
    
    func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
    }
    
    func languageTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromTools)
    }
    
    func toolMenuItemTapped(menuItem: ToolMenuItem) {
        
        switch menuItem.id {
            
        case .lessons:
            // TODO: Implement. ~Levi
            break
        case .favorites:
            selectedToolMenuItem.accept(value: favoritesMenuItem)
        case .allTools:
            selectedToolMenuItem.accept(value: allToolsMenuItem)
        }
    }
}
