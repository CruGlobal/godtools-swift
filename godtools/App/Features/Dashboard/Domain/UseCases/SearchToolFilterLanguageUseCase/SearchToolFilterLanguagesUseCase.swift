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
    
    func getSearchResultsPublisher(for searchTextPublisher: AnyPublisher<String, Never>, in toolFilterLanguagesPublisher: AnyPublisher<[LanguageFilterDomainModel], Never>) -> AnyPublisher<[LanguageFilterDomainModel], Never> {
        
        return Publishers.CombineLatest(
            searchTextPublisher,
            toolFilterLanguagesPublisher
        )
        .flatMap { searchText, toolFilterLanguages in
            
            if searchText.isEmpty {
                
                return Just(toolFilterLanguages)
                
            } else {
                
                let lowercasedSearchText = searchText.lowercased()
                
                let filteredItems = toolFilterLanguages.filter { languageFilter in
                    
                    let lowercasedSearchableText = languageFilter.searchableText.lowercased()
                    
                    return lowercasedSearchableText.contains(lowercasedSearchText)
                }
                
                return Just(filteredItems)
            }
        }
        .eraseToAnyPublisher()
    }
}
