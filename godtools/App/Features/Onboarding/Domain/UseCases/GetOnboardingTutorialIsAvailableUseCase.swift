//
//  GetOnboardingTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetOnboardingTutorialIsAvailableUseCase {
    
    private let launchCountRepository: LaunchCountRepositoryInterface
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepositoryInterface
    
    init(launchCountRepository: LaunchCountRepositoryInterface, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepositoryInterface) {
        
        self.launchCountRepository = launchCountRepository
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func execute() -> AnyPublisher<Bool, Never> {
        
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
