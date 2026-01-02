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
    
    @MainActor func setLanguagePublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Error> {
        
        do {
            
            if let languageModelId = try languagesRepository.cache.getCachedLanguage(code: appLanguage)?.id {
                
                userLessonFiltersRepository.storeUserLessonLanguageFilter(with: languageModelId)
            }
            
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
       
        
        return userAppLanguageRepository
            .storeLanguagePublisher(appLanguageId: appLanguage)
            .setFailureType(to: Error.self)
            .map { _ in
                return appLanguage
            }
            .eraseToAnyPublisher()
    }
}
