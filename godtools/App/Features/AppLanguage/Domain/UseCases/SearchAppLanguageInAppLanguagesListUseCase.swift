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
    
    func getSearchResultsPublisher(for searchTextPublisher: AnyPublisher<String, Never>, in appLanguagesListPublisher: AnyPublisher<[AppLanguageListItemDomainModel], Never>) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            searchTextPublisher,
            appLanguagesListPublisher
        )
        .flatMap { searchText, appLanguagesList in
        
            return self.searchAppLanguageInAppLanguageListRepository.getSearchResultsPublisher(searchText: searchText, appLanguagesList: appLanguagesList)
        }
        .eraseToAnyPublisher()
    }
}
