//
//  SearchToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchToolFilterCategoriesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(for searchTextPublisher: AnyPublisher<String, Never>, in toolFilterCategoriesPublisher: AnyPublisher<[CategoryFilterDomainModel], Never>) -> AnyPublisher<[CategoryFilterDomainModel], Never> {
        
        return Publishers.CombineLatest(
            searchTextPublisher,
            toolFilterCategoriesPublisher
        )
        .flatMap { (searchText, toolFilterLanguages) in
            
            let searchResults = self.stringSearcher.search(for: searchText, in: toolFilterLanguages)
            
            return Just(searchResults)
        }
        .eraseToAnyPublisher()
    }
}
