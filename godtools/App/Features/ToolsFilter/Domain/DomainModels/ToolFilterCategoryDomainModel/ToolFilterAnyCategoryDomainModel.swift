//
//  ToolFilterAnyCategoryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolFilterAnyCategoryDomainModel: ToolFilterCategoryDomainModel {
    
    private static let anyFilterId: String = "any_category"
    
    init(text: String, toolsAvailableText: String) {
        
        super.init(
            id: nil,
            filterId: Self.anyFilterId,
            categoryButtonText: text,
            primaryText: text,
            toolsAvailableText: toolsAvailableText,
            searchableStrings: [text]
        )
    }
    
    static var emptyValue: ToolFilterAnyCategoryDomainModel {
        return ToolFilterAnyCategoryDomainModel(text: "", toolsAvailableText: "")
    }
}
