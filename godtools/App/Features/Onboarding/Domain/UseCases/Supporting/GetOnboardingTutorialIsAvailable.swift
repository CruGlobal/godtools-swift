//
//  GetOnboardingTutorialIsAvailable.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetOnboardingTutorialIsAvailable {
    
    private let launchCountRepository: LaunchCountRepositoryInterface
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    
    init(launchCountRepository: LaunchCountRepositoryInterface, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository) {
        
        self.launchCountRepository = launchCountRepository
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func getIsAvailable() -> Bool {
        
        let launchCount: Int = launchCountRepository.getLaunchCount()
        let tutorialViewed: Bool = onboardingTutorialViewedRepository.getOnboardingTutorialViewed()
        
        let isAvailable = launchCount == 1 && !tutorialViewed
        
        return isAvailable
    }
}
