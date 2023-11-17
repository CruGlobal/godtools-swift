//
//  SearchToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchToolFilterLanguagesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(for searchTextPublisher: AnyPublisher<String, Never>, in toolFilterLanguagesPublisher: AnyPublisher<[LanguageFilterDomainModel], Never>) -> AnyPublisher<[LanguageFilterDomainModel], Never> {
        
        return Publishers.CombineLatest(
            searchTextPublisher,
            toolFilterLanguagesPublisher
        )
        .flatMap { (searchText, toolFilterLanguages) in
            
            let searchResults = self.stringSearcher.search(for: searchText, in: toolFilterLanguages)
            
            return Just(searchResults)
        }
        .eraseToAnyPublisher()
    }
}
