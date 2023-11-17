//
//  CategoryFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct CategoryFilterDomainModel {
    
    let type: CategoryFilterType
    let translatedName: String
    let toolsAvailableText: String
    let searchableText: String
}

extension CategoryFilterDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [searchableText]
    }
}

extension CategoryFilterDomainModel {
    
    var id: String? {
        
        switch type {
        case .anyCategory:
            return nil
        case .category(let id):
            return id
        }
    }
    
    var filterId: String {
        
        switch type {
        case .anyCategory:
            return "any_category"
        case .category(let id):
            return id
        }
    }
}
