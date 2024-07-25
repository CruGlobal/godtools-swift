//
//  ToolFilterCategoryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolFilterCategoryDomainModel: ToolFilterCategoryDomainModelInterface {
    
    let categoryId: String
    let translatedName: String
    let toolsAvailableText: String
    
    var id: String? {
        return categoryId
    }
    
    var filterId: String {
        return categoryId
    }
    
    var categoryButtonText: String {
        return translatedName
    }
    
    var primaryText: String {
        return translatedName
    }
    
    var searchableStrings: [String] {
        return [translatedName]
    }
}
