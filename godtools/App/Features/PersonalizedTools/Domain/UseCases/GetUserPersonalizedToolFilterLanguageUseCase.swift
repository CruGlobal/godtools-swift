//
//  GetUserPersonalizedToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserPersonalizedToolFilterLanguageUseCase: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let mapLanguageToPersonalizedToolFilterLanguage: MapLanguageToPersonalizedToolFilterLanguage
    
    init(
        languagesRepository: LanguagesRepository,
        mapLanguageToPersonalizedToolFilterLanguage: MapLanguageToPersonalizedToolFilterLanguage
    ) {
        
        self.languagesRepository = languagesRepository
        self.mapLanguageToPersonalizedToolFilterLanguage = mapLanguageToPersonalizedToolFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<PersonalizedToolFilterLanguageDomainModel?, Error> {
        
        // TODO: Should observe changes similar to GetUserToolFilterLanguageUseCase. ~Levi
                
        // TODO: Remove. ~Levi
        return Just(getFilterLanguage(appLanguage: appLanguage))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        // End Remove
    }
    
    private func getFilterLanguage(appLanguage: AppLanguageDomainModel) -> PersonalizedToolFilterLanguageDomainModel? {
        
        // TODO: Need to check for user persisted language id and return if exists. ~Levi
        
        if let language = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            return mapLanguageToPersonalizedToolFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return nil
    }
}
