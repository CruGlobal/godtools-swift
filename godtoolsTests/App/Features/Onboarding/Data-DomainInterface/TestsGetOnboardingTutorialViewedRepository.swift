//
//  TestsGetOnboardingTutorialViewedRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetOnboardingTutorialViewedRepository: GetOnboardingTutorialViewedRepositoryInterface {
    
    let tutorialViewed: Bool
    
    init(tutorialViewed: Bool) {
        
        self.tutorialViewed = tutorialViewed
    }
    
    func getViewedPublisher() -> AnyPublisher<Bool, Never> {
        
        return Just(tutorialViewed)
            .eraseToAnyPublisher()
    }
}
