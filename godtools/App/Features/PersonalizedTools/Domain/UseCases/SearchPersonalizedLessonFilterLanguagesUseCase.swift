//
//  SearchPersonalizedLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class SearchPersonalizedLessonFilterLanguagesUseCase: Sendable {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        languages: [ToolLanguageFilterDomainModel]
    ) -> [ToolLanguageFilterDomainModel] {
        
        return stringSearcher.search(for: searchText, in: languages)
    }
}
