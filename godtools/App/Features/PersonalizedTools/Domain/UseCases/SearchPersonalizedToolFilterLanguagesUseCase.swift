//
//  SearchPersonalizedToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class SearchPersonalizedToolFilterLanguagesUseCase: Sendable {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        languages: [PersonalizedToolFilterLanguageDomainModel]
    ) -> [PersonalizedToolFilterLanguageDomainModel] {
        
        return stringSearcher.search(for: searchText, in: languages)
    }
}
