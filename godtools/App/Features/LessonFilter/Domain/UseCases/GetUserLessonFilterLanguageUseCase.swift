//
//  GetUserLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserLessonFilterLanguageUseCase: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    private let getLessonFilterLanguage: GetLessonFilterLanguage
    
    init(
        languagesRepository: LanguagesRepository,
        userLessonFiltersRepository: UserLessonFiltersRepository,
        getLessonFilterLanguage: GetLessonFilterLanguage
    ) {
        
        self.languagesRepository = languagesRepository
        self.userLessonFiltersRepository = userLessonFiltersRepository
        self.getLessonFilterLanguage = getLessonFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserLessonFiltersDomainModel, Error> {
        
        return Publishers.CombineLatest(
            languagesRepository.observeCollectionChangesPublisher(),
            userLessonFiltersRepository.observeCollectionChangesPublisher()
        )
        .map { (languagesChanged: Void, lessonFiltersChanged: Void) in

            return self.getLessonFilterLanguage(appLanguage: appLanguage)
        }
        .map { (languageFilter: LessonFilterLanguageDomainModel?) in

            let userFilters = UserLessonFiltersDomainModel(
                languageFilter: languageFilter
            )

            return userFilters
        }
        .eraseToAnyPublisher()
    }
    
    private func getLessonFilterLanguage(appLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        if let userFilterLanguageId = userLessonFiltersRepository.getUserLessonLanguageFilter()?.languageId,
           let language = languagesRepository.getLanguageById(id: userFilterLanguageId) {
            
            return getLessonFilterLanguage.mapLanguageToLessonFilterLanguage(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        else if let language = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            return getLessonFilterLanguage.mapLanguageToLessonFilterLanguage(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return nil
    }
}
