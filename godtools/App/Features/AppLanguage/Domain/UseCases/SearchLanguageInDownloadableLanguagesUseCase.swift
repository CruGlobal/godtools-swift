//
//  SearchLanguageInDownloadableLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class SearchLanguageInDownloadableLanguagesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        downloadableLanguages: [DownloadableLanguageListItemDomainModel]
    ) async -> [DownloadableLanguageListItemDomainModel] {
        
        return stringSearcher.search(for: searchText, in: downloadableLanguages)
    }
}
