//
//  ToolFilterSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFilterSelectionViewModel: ObservableObject {
    
    var selectedCategory: ToolCategoryDomainModel? = nil
    var selectedLanguage: LanguageDomainModel? = nil
    
    init(toolFilterSelection: ToolFilterSelection) {
        
        self.selectedCategory = toolFilterSelection.selectedCategory
        self.selectedLanguage = toolFilterSelection.selectedLanguage
    }
    
}

// MARK: - Inputs

extension ToolFilterSelectionViewModel {
    
    func getToolFilterSelectionRowViewModel() -> ToolFilterSelectionRowViewModel {
        
        return ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "7 Tools available")
    }
}
