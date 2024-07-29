//
//  ToolFilterCategoryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolFilterCategoryDomainModel: StringSearchable {
    
    let id: String?
    let filterId: String?
    let categoryButtonText: String
    let primaryText: String
    let toolsAvailableText: String
    let searchableStrings: [String]
    
    convenience init(categoryId: String, translatedName: String, toolsAvailableText: String) {
        
        self.init(
            id: categoryId,
            filterId: categoryId,
            categoryButtonText: translatedName,
            primaryText: translatedName,
            toolsAvailableText: toolsAvailableText,
            searchableStrings: [translatedName]
        )
    }
    
    init(id: String?, filterId: String?, categoryButtonText: String, primaryText: String, toolsAvailableText: String, searchableStrings: [String]) {
        
        self.id = id
        self.filterId = filterId
        self.categoryButtonText = categoryButtonText
        self.primaryText = primaryText
        self.toolsAvailableText = toolsAvailableText
        self.searchableStrings = searchableStrings
    }
}
