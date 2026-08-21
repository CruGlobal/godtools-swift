//
//  SearchToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SearchToolFilterCategoriesUseCase: Sendable {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        toolFilterCategories: [ToolFilterCategoryDomainModel]
    ) -> [ToolFilterCategoryDomainModel] {
        
        return stringSearcher.search(for: searchText, in: toolFilterCategories)
    }
}
