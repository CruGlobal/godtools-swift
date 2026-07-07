//
//  SearchToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SearchToolFilterCategoriesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        toolFilterCategories: [ToolFilterCategoryDomainModel]
    ) async -> [ToolFilterCategoryDomainModel] {
        
        return stringSearcher.search(for: searchText, in: toolFilterCategories)
    }
}
