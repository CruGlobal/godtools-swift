//
//  ToolsMenuToolbarItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolsMenuToolbarItemViewModel: ToolsMenuToolbarItemViewModelType {
    
    let title: String
    
    required init(toolMenuItem: ToolMenuItem) {
        
        title = toolMenuItem.title
    }
}
