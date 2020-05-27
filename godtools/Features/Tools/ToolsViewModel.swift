//
//  ToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolsViewModel: ToolsViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let toolMenuItems: ObservableValue<[ToolMenuItem]> = ObservableValue(value: [])
    let selectedToolMenuItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
        
        toolMenuItems.accept(value: [
            ToolMenuItem(id: .favorites, title: NSLocalizedString("my_tools", comment: ""), accessibilityLabel: "my_tools"),
            ToolMenuItem(id: .allTools, title: NSLocalizedString("find_tools", comment: ""), accessibilityLabel: "find_tools")
        ])        
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
