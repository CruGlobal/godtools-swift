//
//  GetOnboardingTutorialAvailabilityUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOnboardingTutorialAvailabilityUseCase {
    
    private let launchCountRepository: LaunchCountRepository
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    
    init(launchCountRepository: LaunchCountRepository, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository) {
        
        self.launchCountRepository = launchCountRepository
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func getOnboardingTutorialIsAvailable() -> OnboardingTutorialAvailabilityDomainModel {
                
        return OnboardingTutorialAvailabilityDomainModel(isAvailable: true)
        
        let launchCount: Int = launchCountRepository.getLaunchCount()
        let onboardingTutorialViewed: Bool = onboardingTutorialViewedRepository.getOnboardingTutorialViewed()
                
        return OnboardingTutorialAvailabilityDomainModel(
            isAvailable: launchCount == 1 && !onboardingTutorialViewed
        )
    }
}
