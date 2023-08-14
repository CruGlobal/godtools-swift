//
//  ToolCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCategoryButtonViewModel: ObservableObject {
        
    let category: ToolCategoryDomainModel
    
    @Published var categoryText: String = ""
    @Published var greyOutText: Bool = false
    @Published var showBorder: Bool = false
            
    init(category: ToolCategoryDomainModel, selectedCategoryId: String?) {
        self.category = category
        
        categoryText = category.translatedName
        
        let buttonState = ToolCategoryButtonState(categoryId: category.id, selectedCategoryId: selectedCategoryId)
        setButtonState(buttonState)
    }

}

// MARK: - Public

extension ToolCategoryButtonViewModel {
    
    func updateStateWithSelectedCategory(_ selectedCategoryId: String?) {
        let buttonState = ToolCategoryButtonState(categoryId: category.id, selectedCategoryId: selectedCategoryId)
        
        setButtonState(buttonState)
    }
}

// MARK: - Private

extension ToolCategoryButtonViewModel {
    
    private func setButtonState(_ state: ToolCategoryButtonState) {
        
        switch state {
            
        case .selected:
            showBorder = true
            greyOutText = false
            
        case .greyedOut:
            showBorder = false
            greyOutText = true
        }
    }
}
