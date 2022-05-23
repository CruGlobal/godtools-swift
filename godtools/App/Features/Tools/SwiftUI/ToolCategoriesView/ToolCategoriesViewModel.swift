//
//  ToolCategoriesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolCategoriesViewModel: ObservableObject {
    
    var buttonViewModels = [ToolCategoryButtonViewModel]()
    
    
    
    init() {
        buttonViewModels = [
            ToolCategoryButtonViewModel(category: "Conversation Starter", buttonState: .notSelected),
            ToolCategoryButtonViewModel(category: "Gospel Invitation", buttonState: .selected),
            ToolCategoryButtonViewModel(category: "Training", buttonState: .greyedOut),
            ToolCategoryButtonViewModel(category: "Christian Growth", buttonState: .greyedOut),
            ToolCategoryButtonViewModel(category: "Survey", buttonState: .greyedOut),
            ToolCategoryButtonViewModel(category: "Article Resources", buttonState: .notSelected),

        ]
    }
}
