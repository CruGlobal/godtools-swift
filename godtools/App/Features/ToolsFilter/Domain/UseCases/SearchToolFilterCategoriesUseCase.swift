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
    
    func execute(for searchText: String, in toolFilterCategories: [ToolFilterCategoryDomainModel]) -> AnyPublisher<[ToolFilterCategoryDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: toolFilterCategories)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
