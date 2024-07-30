//
//  ToolFilterAnyCategoryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolFilterAnyCategoryDomainModel: ToolFilterCategoryDomainModel {
    
    init(text: String, toolsAvailableText: String) {
        
        super.init(
            id: nil,
            filterId: "any_category",
            categoryButtonText: text,
            primaryText: text,
            toolsAvailableText: toolsAvailableText,
            searchableStrings: [text]
        )
    }
}
