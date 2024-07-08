//
//  GetUserLessonFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserLessonFiltersRepository: GetUserLessonFiltersRepositoryInterface {
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    private let getLessonFilterLanguagesRepository: GetLessonFilterLanguagesRepository
    
    init(userLessonFiltersRepository: UserLessonFiltersRepository, getLessonFilterLanguagesRepository: GetLessonFilterLanguagesRepository) {
        self.userLessonFiltersRepository = userLessonFiltersRepository
        self.getLessonFilterLanguagesRepository = getLessonFilterLanguagesRepository
    }
    
    func getUserLessonLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonLanguageFilterDomainModel?, Never> {
        
        return userLessonFiltersRepository.getUserLessonLanguageFilterChangedPublisher()
            .map {
                
                let languageId = self.userLessonFiltersRepository.getUserLessonLanguageFilter()?.languageId
                
                if let languageFilter = self.getLessonFilterLanguagesRepository.getLessonLanguageFilter(from: languageId, translatedInAppLanguage: translatedInAppLanguage) {
                    
                    return languageFilter
                    
                } else {
                    
                    // TODO: - not sure if I can pass the translatedInAppLanguage as the languageId here
                    let currentAppLanguageFilterValue = self.getLessonFilterLanguagesRepository.getLessonLanguageFilter(from: translatedInAppLanguage, translatedInAppLanguage: translatedInAppLanguage)
                    
                    return currentAppLanguageFilterValue
                }
            }
            .eraseToAnyPublisher()
    }
}
