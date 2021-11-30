//
//  MenuItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MenuItemViewModel: MenuItemViewModelType {
    
    let title: String
    let selectionDisabled: Bool
    
    required init(menuItem: MenuItem, selectionDisabled: Bool) {
        
        title = menuItem.title
        self.selectionDisabled = selectionDisabled
    }
}
