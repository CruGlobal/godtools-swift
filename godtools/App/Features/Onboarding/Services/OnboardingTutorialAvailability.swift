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
    private let isNewUserCache: IsNewUserCacheType
    
    required init(tutorialAvailability: TutorialAvailabilityType, onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType, isNewUserCache: IsNewUserCacheType) {
                
        self.tutorialAvailability = tutorialAvailability
        self.onboardingTutorialViewedCache = onboardingTutorialViewedCache
        self.isNewUserCache = isNewUserCache
    }
    
    var onboardingTutorialIsAvailable: Bool {
        return isNewUserCache.isNewUser && !onboardingTutorialViewedCache.onboardingTutorialHasBeenViewed && tutorialAvailability.tutorialIsAvailable
    }
    
    func markOnboardingTutorialViewed() {
        onboardingTutorialViewedCache.cacheOnboardingTutorialViewed()
    }
}
