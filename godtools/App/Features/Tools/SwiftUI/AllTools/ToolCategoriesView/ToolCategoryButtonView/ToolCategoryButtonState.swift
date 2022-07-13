//
//  ToolCategoryButtonState.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum ToolCategoryButtonState {
    case selected
    case greyedOut
    
    init(category: String?, selectedCategory: String?) {

        if selectedCategory == category {
            self = .selected
            
        } else {
            self = .greyedOut
        }
    }
}
