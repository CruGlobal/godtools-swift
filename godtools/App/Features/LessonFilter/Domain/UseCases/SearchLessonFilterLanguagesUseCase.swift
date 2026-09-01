//
//  SearchLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class SearchLessonFilterLanguagesUseCase: Sendable {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        lessonFilterLanguages: [ToolLanguageFilterItemDomainModel]
    ) -> [ToolLanguageFilterItemDomainModel] {
        
        return stringSearcher.search(for: searchText, in: lessonFilterLanguages)
    }
}
