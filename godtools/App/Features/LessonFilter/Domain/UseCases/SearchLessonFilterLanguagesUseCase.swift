//
//  SearchLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchLessonFilterLanguagesUseCase {
    
    private let searchLessonFilterLanguagesRepository: SearchLessonFilterLanguagesRepositoryInterface
    
    init(searchLessonFilterLanguagesRepository: SearchLessonFilterLanguagesRepositoryInterface) {
        self.searchLessonFilterLanguagesRepository = searchLessonFilterLanguagesRepository
    }
    
    func getSearchResultsPublisher(for searchText: String, in lessonFilterLanguages: [LessonFilterLanguageDomainModel]) -> AnyPublisher<[LessonFilterLanguageDomainModel], Never> {
        
        return searchLessonFilterLanguagesRepository.getSearchResultsPublisher(for: searchText, in: lessonFilterLanguages)
    }
}
