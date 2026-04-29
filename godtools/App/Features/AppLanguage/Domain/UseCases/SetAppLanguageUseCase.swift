//
//  SetAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SetAppLanguageUseCase {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    private let languagesRepository: LanguagesRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository, userLessonFiltersRepository: UserLessonFiltersRepository, languagesRepository: LanguagesRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
        self.userLessonFiltersRepository = userLessonFiltersRepository
        self.languagesRepository = languagesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Error> {
        
        if let languageModelId = languagesRepository.getLanguage(code: appLanguage)?.id {
            
            Task {
                try await userLessonFiltersRepository.storeUserLessonLanguageFilter(
                    languageId: languageModelId
                )
            }
        }
        
        return userAppLanguageRepository
            .storeLanguagePublisher(appLanguageId: appLanguage)
            .map { _ in
                return appLanguage
            }
            .eraseToAnyPublisher()
    }
}
