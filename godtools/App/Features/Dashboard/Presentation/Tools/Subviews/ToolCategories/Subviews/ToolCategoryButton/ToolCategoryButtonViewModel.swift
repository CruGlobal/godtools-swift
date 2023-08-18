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
    
    @Published var title: String = ""
            
    init(category: ToolCategoryDomainModel) {
        
        self.category = category
        
        title = category.translatedName
    }
}
