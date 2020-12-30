//
//  MenuCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MenuCellViewModel {
    
    let title: String
    let selectionDisabled: Bool
    let hidesSeparator: Bool
    
    required init(menuItem: MenuItem, selectionDisabled: Bool, hidesSeparator: Bool) {
        title = menuItem.title
        self.selectionDisabled = selectionDisabled
        self.hidesSeparator = hidesSeparator
    }
}
