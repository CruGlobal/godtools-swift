//
//  SearchLanguageInDownloadableLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchLanguageInDownloadableLanguagesUseCase {
    
    private let searchLanguageInDownloadableLanguagesRepository: SearchLanguageInDownloadableLanguagesRepositoryInterface
    
    init(searchLanguageInDownloadableLanguagesRepository: SearchLanguageInDownloadableLanguagesRepositoryInterface) {
        
        self.searchLanguageInDownloadableLanguagesRepository = searchLanguageInDownloadableLanguagesRepository
    }
    
    func getSearchResultsPublisher(for searchText: String, in downloadableLanguages: [DownloadableLanguageListItemDomainModel]) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        return searchLanguageInDownloadableLanguagesRepository.getSearchResultsPublisher(searchText: searchText, downloadableLanguagesList: downloadableLanguages)
    }
}
