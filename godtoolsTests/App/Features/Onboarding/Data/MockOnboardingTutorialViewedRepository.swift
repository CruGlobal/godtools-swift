//
//  MockOnboardingTutorialViewedRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class MockOnboardingTutorialViewedRepository: OnboardingTutorialViewedRepositoryInterface {
    
    private let tutorialViewed: Bool
    
    init(tutorialViewed: Bool) {
        
        self.tutorialViewed = tutorialViewed
    }
    
    func getOnboardingTutorialViewedPublisher() -> AnyPublisher<Bool, Never> {
        
        return Just(tutorialViewed)
            .eraseToAnyPublisher()
    }
}
