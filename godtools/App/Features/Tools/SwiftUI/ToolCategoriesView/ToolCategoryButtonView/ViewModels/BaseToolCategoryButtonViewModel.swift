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
    var state: ToolCategoryButtonState
    
    // MARK: - Published
    
    @Published var showBorder: Bool = false
    @Published var greyOutText: Bool = false
    
    // MARK: - Init
    
    init(categoryText: String, buttonState: ToolCategoryButtonState) {
        self.categoryText = categoryText
        self.state = buttonState
        
        setPublishedValues()
    }
}

// MARK: - Public

extension BaseToolCategoryButtonViewModel {
    func setPublishedValues() {
        
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
