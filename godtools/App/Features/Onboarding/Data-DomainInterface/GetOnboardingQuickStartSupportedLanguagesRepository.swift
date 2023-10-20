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
    
    private let supportedLanguages: [LanguageCodeDomainModel] = [.english, .french, .latvian, .spanish, .vietnamese]
    
    init() {
        
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageCodeDomainModel], Never> {
        
        return Just(supportedLanguages)
            .eraseToAnyPublisher()
    }
}
