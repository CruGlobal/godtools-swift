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
    
    func getUserLessonLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguageDomainModel?, Never> {
        
        return userLessonFiltersRepository.getUserLessonLanguageFilterChangedPublisher()
            .map {
                
                let languageId = self.userLessonFiltersRepository.getUserLessonLanguageFilter()?.languageId
                
                if let languageFilter = self.getLessonFilterLanguagesRepository.getLessonLanguageFilterFromLanguageId(languageId: languageId, translatedInAppLanguage: translatedInAppLanguage) {
                    
                    return languageFilter
                    
                } else {
                    
                    let currentAppLanguageFilterValue = self.getLessonFilterLanguagesRepository.getLessonLanguageFilterFromLanguageCode(languageCode: translatedInAppLanguage, translatedInAppLanguage: translatedInAppLanguage)
                    
                    return currentAppLanguageFilterValue
                }
            }
            .eraseToAnyPublisher()
    }
}
