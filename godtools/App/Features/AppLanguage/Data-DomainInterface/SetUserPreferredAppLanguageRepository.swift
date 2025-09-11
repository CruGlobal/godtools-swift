//
//  SetUserPreferredAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetUserPreferredAppLanguageRepository: SetUserPreferredAppLanguageRepositoryInterface {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    private let languagesRepository: LanguagesRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository, userLessonFiltersRepository: UserLessonFiltersRepository, languagesRepository: LanguagesRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
        self.userLessonFiltersRepository = userLessonFiltersRepository
        self.languagesRepository = languagesRepository
    }
    
    func setLanguagePublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        if let languageModelId = languagesRepository.getCachedLanguage(code: appLanguage)?.id {
            
            userLessonFiltersRepository.storeUserLessonLanguageFilter(with: languageModelId)
        }
        
        return userAppLanguageRepository.storeLanguagePublisher(appLanguageId: appLanguage)
            .map { _ in
                return appLanguage
            }
            .eraseToAnyPublisher()
    }
}
