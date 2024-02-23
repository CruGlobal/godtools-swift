//
//  SearchAppLanguageInAppLanguagesListRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchAppLanguageInAppLanguagesListRepository: SearchAppLanguageInAppLanguagesListRepositoryInterface {
    
    let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: appLanguagesList)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
