//
//  ToolsMenuToolbarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolsMenuToolbarViewModel: ToolsMenuToolbarViewModelType {
    
    let numberOfToolbarItems: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init() {
        
    }
}
