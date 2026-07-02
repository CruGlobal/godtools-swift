//
//  ToolFilterCategoryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolFilterCategoryDomainModel: Sendable, Identifiable {
    
    private static let anyCategoryId: String = "any_category"
    
    enum CategoryType: Sendable {
        case any
        case category
    }
    
    let id: String
    let title: String
    let toolsAvailable: String
    let categoryType: CategoryType
    
    var filterId: String? {
        switch categoryType {
        case .any:
            return nil
        case .category:
            return id
        }
    }
    
    private init(id: String, title: String, toolsAvailable: String, categoryType: CategoryType) {
        self.id = id
        self.title = title
        self.toolsAvailable = toolsAvailable
        self.categoryType = categoryType
    }
    
    static func createAnyCategory(title: String, toolsAvailable: String) -> ToolFilterCategoryDomainModel {
        
        return ToolFilterCategoryDomainModel(
            id: Self.anyCategoryId,
            title: title,
            toolsAvailable: toolsAvailable,
            categoryType: .any
        )
    }
    
    static func createCategory(id: String, title: String, toolsAvailable: String) -> ToolFilterCategoryDomainModel {
        
        return ToolFilterCategoryDomainModel(
            id: id,
            title: title,
            toolsAvailable: toolsAvailable,
            categoryType: .category
        )
    }
    
    static var emptyValue: ToolFilterCategoryDomainModel {
        return Self.createAnyCategory(title: "", toolsAvailable: "")
    }
}

extension ToolFilterCategoryDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [title]
    }
}
