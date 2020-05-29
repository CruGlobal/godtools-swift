//
//  ToolsMenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolsMenuViewModel: ToolsMenuViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let toolMenuItems: ObservableValue<[ToolMenuItem]> = ObservableValue(value: [])
    let selectedToolMenuItem: ObservableValue<ToolMenuItem?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
        
        reloadToolMenu()
    }
    
    private func reloadToolMenu() {
        
        let favorites: ToolMenuItem = ToolMenuItem(id: .favorites, title: NSLocalizedString("my_tools", comment: ""), accessibilityLabel: "my_tools")
        let allTools: ToolMenuItem = ToolMenuItem(id: .allTools, title: NSLocalizedString("find_tools", comment: ""), accessibilityLabel: "find_tools")
        
        toolMenuItems.accept(value: [favorites, allTools])
        selectedToolMenuItem.accept(value: favorites)
    }
    
    func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
    }
    
    func languageTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromTools)
    }
    
    func toolMenuItemTapped(menuItem: ToolMenuItem) {
        
        switch menuItem.id {
            
        case .favorites:
            print("\n FAVORITES TAPPED!")
        case .allTools:
            print("\n ALL TOOLS TAPPED")
        }
    }
}
