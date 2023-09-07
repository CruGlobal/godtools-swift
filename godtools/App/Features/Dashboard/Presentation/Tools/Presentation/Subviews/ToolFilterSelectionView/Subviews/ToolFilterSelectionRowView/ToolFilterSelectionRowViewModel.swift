//
//  ToolFilterSelectionRowViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFilterSelectionRowViewModel: ObservableObject {
    
    enum FilterValue {
        case any
        case some(filterValueId: String)
    }
    
    let title: String
    let subtitle: String?
    let toolsAvailableText: String
    let filterValue: FilterValue
    
    init(title: String, subtitle: String?, toolsAvailableText: String, filterValue: FilterValue) {
        
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
        case .any:
            return "any_filter"
            
        case .some(let filterValueId):
            return filterValueId
        }
    }
}
