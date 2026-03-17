//
//  GetUserLessonFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserLessonFiltersUseCase {
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    private let getLessonFilterLanguage: GetLessonFilterLanguage
    
    init(userLessonFiltersRepository: UserLessonFiltersRepository, getLessonFilterLanguage: GetLessonFilterLanguage) {
        
        self.userLessonFiltersRepository = userLessonFiltersRepository
        self.getLessonFilterLanguage = getLessonFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserLessonFiltersDomainModel, Never> {
        
        return userLessonFiltersRepository
            .getUserLessonLanguageFilterChangedPublisher()
            .map { _ in
                
                let languageId: String? = self.userLessonFiltersRepository.getUserLessonLanguageFilter()?.languageId
                
                if let languageId = languageId,
                   let languageFilter = self.getLessonFilterLanguage.getLessonLanguageFilterFromLanguageId(languageId: languageId, translatedInAppLanguage: appLanguage) {
                    
                    return languageFilter
                }
                
                return self.getLessonFilterLanguage.getLessonLanguageFilterFromLanguageCode(
                    languageCode: appLanguage,
                    translatedInAppLanguage: appLanguage
                )
            }
            .map { (languageFilter: LessonFilterLanguageDomainModel?) in
                
                let userFilters = UserLessonFiltersDomainModel(
                    languageFilter: languageFilter
                )

                return userFilters
            }
            .eraseToAnyPublisher()
    }
}
