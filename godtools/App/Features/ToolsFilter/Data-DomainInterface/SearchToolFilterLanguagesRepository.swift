//
//  SearchToolFilterLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 3/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchToolFilterLanguagesRepository: SearchToolFilterLanguagesRepositoryInterface {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(for searchText: String, in toolFilterLanguages: [LanguageFilterDomainModel]) -> AnyPublisher<[LanguageFilterDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: toolFilterLanguages)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
