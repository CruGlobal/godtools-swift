//
//  SearchLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class SearchLessonFilterLanguagesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func execute(for searchText: String, in lessonFilterLanguages: [LessonFilterLanguageDomainModel]) -> AnyPublisher<[LessonFilterLanguageDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: lessonFilterLanguages)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
