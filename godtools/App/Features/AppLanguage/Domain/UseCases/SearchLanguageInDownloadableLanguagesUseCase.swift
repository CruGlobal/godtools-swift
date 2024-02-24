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
    
    func getSearchResultsPublisher(for searchTextPublisher: AnyPublisher<String, Never>, in downloadableLanguagesPublisher: AnyPublisher<[DownloadableLanguageListItemDomainModel], Never>) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            searchTextPublisher,
            downloadableLanguagesPublisher
        )
        .flatMap { searchText, downloadableLanguagesList in
        
            return self.searchLanguageInDownloadableLanguagesRepository.getSearchResultsPublisher(searchText: searchText, appLanguagesList: downloadableLanguagesList)
        }
        .eraseToAnyPublisher()
    }
}
