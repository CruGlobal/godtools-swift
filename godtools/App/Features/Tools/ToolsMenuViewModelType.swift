//
//  ToolsMenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsMenuViewModelType {
        
    var favoritesMenuItem: ToolMenuItem { get }
    var allToolsMenuItem: ToolMenuItem { get }
    var toolMenuItems: ObservableValue<[ToolMenuItem]> { get }
    var selectedToolMenuItem: ObservableValue<ToolMenuItem?> { get }
    
    func resetMenu()
    func menuTapped()
    func languageTapped()
    func toolMenuItemTapped(menuItem: ToolMenuItem)
}
