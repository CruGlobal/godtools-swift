//
//  SearchLanguageInDownloadableLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class SearchLanguageInDownloadableLanguagesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func execute(searchText: String, downloadableLanguages: [DownloadableLanguageListItemDomainModel]) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: downloadableLanguages)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
