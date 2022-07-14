//
//  BaseToolCategoryButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class BaseToolCategoryButtonViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let categoryText: String
    
    // MARK: - Published
    
    @Published var showBorder: Bool = false
    @Published var greyOutText: Bool = false
    
    // MARK: - Init
    
    init(categoryText: String, buttonState: ToolCategoryButtonState) {
        self.categoryText = categoryText
        
        setButtonState(buttonState)
    }
    
    // MARK: - For Override
    
    func updateStateWithSelectedCategory(_ selectedAttrCategory: String?) {}
}

// MARK: - Public

extension BaseToolCategoryButtonViewModel {
    
    func setButtonState(_ state: ToolCategoryButtonState) {
        
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
