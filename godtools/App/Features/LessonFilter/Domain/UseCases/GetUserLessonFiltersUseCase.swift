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
        .flatMap { (languagesChanged: Void, lessonFiltersChanged: Void) -> AnyPublisher<LessonFilterLanguageDomainModel?, Error> in

            return AnyPublisher() {
                
                return await self.asyncExecute(appLanguage: appLanguage)
            }
        }
        .map { (languageFilter: LessonFilterLanguageDomainModel?) in

            let userFilters = UserLessonFiltersDomainModel(
                languageFilter: languageFilter
            )

            return userFilters
        }
        .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async -> LessonFilterLanguageDomainModel? {
        
        let languageId: String? = userLessonFiltersRepository.getUserLessonLanguageFilter()?.languageId

        if let languageId = languageId,
           let languageFilter = await getLessonFilterLanguage.getLessonLanguageFilterFromLanguageId(languageId: languageId, translatedInAppLanguage: appLanguage) {

            return languageFilter
        }

        return await getLessonFilterLanguage.getLessonLanguageFilterFromLanguageCode(
            languageCode: appLanguage,
            translatedInAppLanguage: appLanguage
        )
    }
}
