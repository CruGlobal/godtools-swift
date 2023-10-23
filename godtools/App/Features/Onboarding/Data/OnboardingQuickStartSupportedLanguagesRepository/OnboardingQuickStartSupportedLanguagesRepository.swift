//
//  OnboardingQuickStartSupportedLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class OnboardingQuickStartSupportedLanguagesRepository {
    
    private let cache: OnboardingQuickStartSupportedLanguagesCache
    
    init(cache: OnboardingQuickStartSupportedLanguagesCache) {
        
        self.cache = cache
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageCodeDomainModel], Never> {
        
        return Just(cache.getSupportedLanguages())
            .eraseToAnyPublisher()
    }
}
