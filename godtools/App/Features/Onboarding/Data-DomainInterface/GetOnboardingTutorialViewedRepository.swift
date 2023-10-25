//
//  GetOnboardingTutorialViewedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingTutorialViewedRepository: GetOnboardingTutorialViewedRepositoryInterface {
    
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    
    init(onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository) {
        
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func getViewedPublisher() -> AnyPublisher<Bool, Never> {
        
        let viewed: Bool = onboardingTutorialViewedRepository.getOnboardingTutorialViewed()
        
        return Just(viewed)
            .eraseToAnyPublisher()
    }
}
