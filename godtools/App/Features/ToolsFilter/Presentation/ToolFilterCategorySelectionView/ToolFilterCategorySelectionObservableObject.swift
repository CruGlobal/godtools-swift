//
//  ToolFilterCategorySelectionObservableObject.swift
//  godtools
//
//  Created by Levi Eggert on 3/18/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolFilterCategorySelectionObservableObject: ObservableObject {
    
    @Published var toolFilterCategory: CategoryFilterDomainModel
    
    init(toolFilterCategory: CategoryFilterDomainModel) {
        
        self.toolFilterCategory = toolFilterCategory
    }
}
