//
//  SearchLessonFilterLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchLessonFilterLanguagesRepository: SearchLessonFilterLanguagesRepositoryInterface {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func getSearchResultsPublisher(for searchText: String, in lessonFilterLanguages: [LessonLanguageFilterDomainModel]) -> AnyPublisher<[LessonLanguageFilterDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: lessonFilterLanguages)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
