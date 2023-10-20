//
//  TestsGetOnboardingQuickStartSupportedLanguagesRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetOnboardingQuickStartSupportedLanguagesRepository: GetOnboardingQuickStartSupportedLanguagesRepositoryInterface {
    
    private let supportedLanguages: [LanguageCodeDomainModel]
    
    init(supportedLanguages: [LanguageCodeDomainModel]) {
        
        self.supportedLanguages = supportedLanguages
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageCodeDomainModel], Never> {
        
        return Just(supportedLanguages)
            .eraseToAnyPublisher()
    }
}
