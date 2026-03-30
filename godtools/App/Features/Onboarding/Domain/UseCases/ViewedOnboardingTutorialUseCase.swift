//
//  ViewedOnboardingTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class ViewedOnboardingTutorialUseCase {
    
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    
    init(onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository) {
        
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func execute() -> AnyPublisher<Void, Never> {
        
        onboardingTutorialViewedRepository.storeOnboardingTutorialViewed(viewed: true)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
