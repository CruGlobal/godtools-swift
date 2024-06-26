//
//  SearchLanguageInDownloadableLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchLanguageInDownloadableLanguagesRepository: SearchLanguageInDownloadableLanguagesRepositoryInterface {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(searchText: String, downloadableLanguagesList: [DownloadableLanguageListItemDomainModel]) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: downloadableLanguagesList)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
