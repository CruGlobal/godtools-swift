//
//  GetOnboardingQuickStartSupportedLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickStartSupportedLanguagesRepository: GetOnboardingQuickStartSupportedLanguagesRepositoryInterface {
    
    private let onboardingQuickStartSupportedLanguagesRepository: OnboardingQuickStartSupportedLanguagesRepository
        
    init(onboardingQuickStartSupportedLanguagesRepository: OnboardingQuickStartSupportedLanguagesRepository) {
        
        self.onboardingQuickStartSupportedLanguagesRepository = onboardingQuickStartSupportedLanguagesRepository
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageCodeDomainModel], Never> {
        
        return onboardingQuickStartSupportedLanguagesRepository.getLanguagesPublisher()
            .eraseToAnyPublisher()
    }
}
