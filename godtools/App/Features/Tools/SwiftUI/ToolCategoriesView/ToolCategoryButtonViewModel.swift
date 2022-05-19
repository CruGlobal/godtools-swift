//
//  ToolCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum ToolCategoryButtonState {
    case notSelected
    case selected
    case greyedOut
    
    init(category: String, selectedCategory: String?) {
        guard let selectedCategory = selectedCategory else {
            self = .notSelected
            return
        }

        if selectedCategory == category {
            self = .selected
            
        } else {
            self = .greyedOut
        }
    }
}

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
