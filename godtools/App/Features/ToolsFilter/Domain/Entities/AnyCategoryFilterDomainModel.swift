//
//  AnyCategoryFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct AnyCategoryFilterDomainModel: CategoryFilterDomainModelInterface {
    
    let text: String
    let toolsAvailableText: String
    
    let id: String? = nil
    let filterId: String = "any_category"
    
    var categoryButtonText: String {
        return text
    }
    
    var primaryText: String {
        return text
    }
    
    var searchableStrings: [String] {
        return [text]
    }
}
