//
//  MockOnboardingTutorialViewedRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class MockOnboardingTutorialViewedRepository: OnboardingTutorialViewedRepositoryInterface {
    
    private var tutorialViewed: Bool = false
    
    init(tutorialViewed: Bool) {
        
        self.tutorialViewed = tutorialViewed
    }
    
    func getOnboardingTutorialViewed() -> Bool {
        return tutorialViewed
    }
    
    func getOnboardingTutorialViewedPublisher() -> AnyPublisher<Bool, Never> {
        return Just(tutorialViewed)
            .eraseToAnyPublisher()
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) {
        tutorialViewed = viewed
    }
}
