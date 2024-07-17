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
    
    private let searchToolFilterCategoriesRepository: SearchToolFilterCategoriesRepositoryInterface
    
    init(searchToolFilterCategoriesRepository: SearchToolFilterCategoriesRepositoryInterface) {
        
        self.searchToolFilterCategoriesRepository = searchToolFilterCategoriesRepository
    }
    
    func getSearchResultsPublisher(for searchText: String, in toolFilterCategories: [CategoryFilterDomainModel]) -> AnyPublisher<[CategoryFilterDomainModel], Never> {
        
        return searchToolFilterCategoriesRepository.getSearchResultsPublisher(for: searchText, in: toolFilterCategories)
    }
}
