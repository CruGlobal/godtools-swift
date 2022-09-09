//
//  ToolCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCategoryButtonViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let category: ToolCategoryDomainModel
    private let localizationServices: LocalizationServices

    // MARK: - Published
    
    @Published var categoryText: String = ""
    @Published var greyOutText: Bool = false
    @Published var showBorder: Bool = false
        
    // MARK: - Init
    
    init(category: ToolCategoryDomainModel, selectedCategoryId: String?, localizationServices: LocalizationServices) {
        self.category = category
        self.localizationServices = localizationServices
        
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
