//
//  ToolMenuItem.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ToolMenuItem {
    
    let id: ToolMenuItemId
    let title: String
    
    init(id: ToolMenuItemId, title: String, accessibilityLabel: String) {
        self.id = id
        self.title = title
        
        (self.title as NSString).accessibilityLabel = accessibilityLabel
    }
}

extension ToolMenuItem: Equatable {
    static func ==(lhs: ToolMenuItem, rhs: ToolMenuItem) -> Bool {
        return lhs.id == rhs.id
    }
}
