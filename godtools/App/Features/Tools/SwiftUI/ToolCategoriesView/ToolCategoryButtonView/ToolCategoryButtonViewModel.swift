//
//  ToolCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCategoryButtonViewModel: ObservableObject {
    
    let category: String
    var state: ToolCategoryButtonState
    
    @Published var showBorder: Bool = false
    @Published var greyOutText: Bool = false
    
    init(category: String, selectedCategory: String?) {
        self.category = category
        state = ToolCategoryButtonState(category: category, selectedCategory: selectedCategory)
        
        setPublishedValues()
    }
    
    init(category: String, buttonState: ToolCategoryButtonState) {
        self.category = category
        self.state = buttonState
        
        setPublishedValues()
    }
}

// MARK: - Private

extension ToolCategoryButtonViewModel {
    
    private func setPublishedValues() {
        
        switch state {
        case .notSelected:
            showBorder = false
            greyOutText = false
            
        case .selected:
            showBorder = true
            greyOutText = false
            
        case .greyedOut:
            showBorder = false
            greyOutText = true
        }
    }
}
