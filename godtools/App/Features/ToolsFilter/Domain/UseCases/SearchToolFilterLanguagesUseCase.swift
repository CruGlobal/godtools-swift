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
    
    private let searchToolFilterLanguagesRepository: SearchToolFilterLanguagesRepositoryInterface
    
    init(searchToolFilterLanguagesRepository: SearchToolFilterLanguagesRepositoryInterface) {
        
        self.searchToolFilterLanguagesRepository = searchToolFilterLanguagesRepository
    }
    
    func getSearchResultsPublisher(for searchText: String, in toolFilterLanguages: [ToolFilterLanguageDomainModel]) -> AnyPublisher<[ToolFilterLanguageDomainModel], Never> {
        
        return searchToolFilterLanguagesRepository.getSearchResultsPublisher(for: searchText, in: toolFilterLanguages)
    }
}
