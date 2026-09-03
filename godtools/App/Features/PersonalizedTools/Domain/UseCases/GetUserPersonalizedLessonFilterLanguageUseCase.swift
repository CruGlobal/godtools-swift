//
//  GetUserPersonalizedLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserPersonalizedLessonFilterLanguageUseCase: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let mapLanguageToPersonalizedLessonFilterLanguage: MapLanguageToPersonalizedLessonFilterLanguage
    
    init(
        languagesRepository: LanguagesRepository,
        mapLanguageToPersonalizedLessonFilterLanguage: MapLanguageToPersonalizedLessonFilterLanguage
    ) {
        
        self.languagesRepository = languagesRepository
        self.mapLanguageToPersonalizedLessonFilterLanguage = mapLanguageToPersonalizedLessonFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<PersonalizedLessonFilterLanguageDomainModel?, Error> {
        
        // TODO: Should observe changes similar to GetUserLessonFilterLanguageUseCase. ~Levi
                
        // TODO: Remove. ~Levi
        return Just(getFilterLanguage(appLanguage: appLanguage))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        // End Remove
    }
    
    private func getFilterLanguage(appLanguage: AppLanguageDomainModel) -> PersonalizedLessonFilterLanguageDomainModel? {
        
        // TODO: Need to check for user persisted language id and return if exists. ~Levi
        
        if let language = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            return mapLanguageToPersonalizedLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return nil
    }
}
