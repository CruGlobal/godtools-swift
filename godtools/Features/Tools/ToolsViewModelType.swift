//
//  ToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsViewModelType {
        
    var toolMenuItems: ObservableValue<[ToolMenuItem]> { get }
    var selectedToolMenuItemIndex: ObservableValue<Int> { get }
    
    func menuTapped()
    func languageTapped()
    func toolMenuItemTapped(menuItem: ToolMenuItem)
}
