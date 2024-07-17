//
//  CategoryFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum CategoryFilterDomainModel {
    case anyCategory(text: String, toolsAvailableText: String)
    case category(categoryId: String, translatedName: String, toolsAvailableText: String)
}

extension CategoryFilterDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        
        switch self {
        case .anyCategory(let text, _):
            return [text]
        case .category(_, let translatedName, _):
            return [translatedName]
        }
    }
}

extension CategoryFilterDomainModel {
    
    var id: String? {
        
        switch self {
        case .anyCategory:
            return nil
        case .category(let id, _, _):
            return id
        }
    }
    
    var filterId: String {
        
        switch self {
        case .anyCategory:
            return "any_category"
        case .category(let id, _, _):
            return id
        }
    }
    
    var categoryButtonText: String {
        
        switch self {
        case .anyCategory(let text, _):
            return text
        case .category(_, let translatedName, _):
            return translatedName
        }
    }
    
    var primaryText: String {
        
        switch self {
        case .anyCategory(let text, _):
            return text
        case .category(_, let translatedName, _):
            return translatedName
        }
    }
    
    var toolsAvailableText: String {
        
        switch self {
        case .anyCategory(_, let toolsAvailableText):
            return toolsAvailableText
        case .category(_, _, let toolsAvailableText):
            return toolsAvailableText
        }
    }
}
