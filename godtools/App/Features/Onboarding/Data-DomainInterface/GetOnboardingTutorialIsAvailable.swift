//
//  GetOnboardingTutorialIsAvailable.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface {
    
    private let launchCountRepository: LaunchCountRepository
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    
    init(launchCountRepository: LaunchCountRepository, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository) {
        
        self.launchCountRepository = launchCountRepository
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func isAvailablePublisher() -> AnyPublisher<Bool, Never> {
        
        Publishers.CombineLatest(
            launchCountRepository.getLaunchCountPublisher(),
            onboardingTutorialViewedRepository.getOnboardingTutorialViewedPublisher()
        )
        .flatMap({ (launchCount: Int, tutorialViewed: Bool) -> AnyPublisher<Bool, Never> in
            
            let isAvailable = launchCount == 1 && !tutorialViewed
            
            return Just(isAvailable)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
