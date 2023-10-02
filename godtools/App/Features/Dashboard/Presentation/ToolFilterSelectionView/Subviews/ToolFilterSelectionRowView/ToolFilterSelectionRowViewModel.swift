//
//  ToolFilterSelectionRowViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFilterSelectionRowViewModel: ObservableObject {
    
    let title: String
    let subtitle: String?
    let toolsAvailableText: String
    let filterValue: ToolFilterValue
    
    init(title: String, subtitle: String?, toolsAvailableText: String, filterValue: ToolFilterValue) {
        
        self.title = title
        self.subtitle = subtitle
        self.toolsAvailableText = toolsAvailableText
        self.filterValue = filterValue
    }
}

// MARK: - Identifiable

extension ToolFilterSelectionRowViewModel: Identifiable {

    var id: String {
        
        switch filterValue {
            
        case .category(let categoryModel):
            
            switch categoryModel.type {
            case .anyCategory:
                return "any_category"
                
            case .category(let categoryId):
                return categoryId
            }
            
        case .language(let languageModel):
            
            switch languageModel.type {
            case .anyLanguage:
                return "any_language"
                
            case .language(let languageModel):
                return languageModel.id
            }
        }
    }
}
