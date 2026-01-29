//
//  GetUserLessonFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserLessonFiltersUseCase {
    
    private let getUserLessonFiltersRepositoryInterface: GetUserLessonFiltersRepositoryInterface
    
    init(getUserLessonFiltersRepositoryInterface: GetUserLessonFiltersRepositoryInterface) {
        self.getUserLessonFiltersRepositoryInterface = getUserLessonFiltersRepositoryInterface
    }
    
    @MainActor func getUserToolFiltersPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<UserLessonFiltersDomainModel, Never> {
        
        return getUserLessonFiltersRepositoryInterface
            .getUserLessonLanguageFilterPublisher(translatedInAppLanguage: translatedInAppLanguage)
            .flatMap { languageFilter in
                
                let userFilters = UserLessonFiltersDomainModel(
                    languageFilter: languageFilter
                )
                
                return Just(userFilters)
            }
            .eraseToAnyPublisher()
    }
}
