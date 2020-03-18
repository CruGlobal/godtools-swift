//
//  OnboardingTutorialAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialAvailability: OnboardingTutorialAvailabilityType {
    
    private let tutorialAvailability: TutorialAvailabilityType
    private let onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType
    
    required init(tutorialAvailability: TutorialAvailabilityType, onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType) {
                
        self.tutorialAvailability = tutorialAvailability
        self.onboardingTutorialViewedCache = onboardingTutorialViewedCache
    }
    
    var onboardingTutorialIsAvailable: Bool {
        return !onboardingTutorialViewedCache.onboardingTutorialHasBeenViewed && tutorialAvailability.tutorialIsAvailable
    }
    
    func markOnboardingTutorialViewed() {
        onboardingTutorialViewedCache.cacheOnboardingTutorialViewed()
    }
}
