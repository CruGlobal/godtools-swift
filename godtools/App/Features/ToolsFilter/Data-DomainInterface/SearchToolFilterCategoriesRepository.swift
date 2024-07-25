//
//  SearchToolFilterCategoriesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 3/6/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchToolFilterCategoriesRepository: SearchToolFilterCategoriesRepositoryInterface {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(for searchText: String, in toolFilterCategories: [CategoryFilterDomainModelInterface]) -> AnyPublisher<[CategoryFilterDomainModelInterface], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: toolFilterCategories) as? [CategoryFilterDomainModelInterface]
        
        return Just(searchResults ?? [])
            .eraseToAnyPublisher()
    }
}
