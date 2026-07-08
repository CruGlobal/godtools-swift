//
//  SearchToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SearchToolFilterLanguagesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        toolFilterLanguages: [ToolFilterLanguageDomainModel]
    ) async -> [ToolFilterLanguageDomainModel] {
        
        return stringSearcher.search(for: searchText, in: toolFilterLanguages)
    }
}
