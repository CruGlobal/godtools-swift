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
    let filterValueId: String
    
    init(title: String, subtitle: String?, toolsAvailableText: String, filterValueId: String) {
        
        self.title = title
        self.subtitle = subtitle
        self.toolsAvailableText = toolsAvailableText
        self.filterValueId = filterValueId
    }
}

// MARK: - Identifiable

extension ToolFilterSelectionRowViewModel: Identifiable {
    
    var id: String {
        return filterValueId
    }
}
