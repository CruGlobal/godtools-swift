//
//  SearchAppLanguageInAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchAppLanguageInAppLanguagesListUseCase {
    
    private let searchAppLanguageInAppLanguageListRepository: SearchAppLanguageInAppLanguagesListRepositoryInterface
    
    init(searchAppLanguageInAppLanguageListRepository: SearchAppLanguageInAppLanguagesListRepositoryInterface) {
        
        self.searchAppLanguageInAppLanguageListRepository = searchAppLanguageInAppLanguageListRepository
    }
    
    func getSearchResultsPublisher(for searchText: String, in appLanguagesList: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return searchAppLanguageInAppLanguageListRepository.getSearchResultsPublisher(searchText: searchText, appLanguagesList: appLanguagesList)
    }
}
