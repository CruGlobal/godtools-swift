//
//  ToolFiltersViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFiltersViewModel: ObservableObject {
    
    var selectedCategory: ToolCategoryDomainModel? = nil
    var selectedLanguage: LanguageDomainModel? = nil
    
    @Published var categoryButtonTitle: String = ""
    @Published var languageButtonTitle: String = ""
    
    init() {
        
        categoryButtonTitle = "Any category"
        languageButtonTitle = "Any language"
    }
}
