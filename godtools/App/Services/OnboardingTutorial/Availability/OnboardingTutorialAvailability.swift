//
//  OnboardingTutorialAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialAvailability: OnboardingTutorialAvailabilityType {
    
    private let onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType
    private let isNewUserCache: IsNewUserDefaultsCache
    
    required init(onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType, isNewUserCache: IsNewUserDefaultsCache) {
                
        self.onboardingTutorialViewedCache = onboardingTutorialViewedCache
        self.isNewUserCache = isNewUserCache
    }
    
    var onboardingTutorialIsAvailable: Bool {
        return isNewUserCache.isNewUser && !onboardingTutorialViewedCache.onboardingTutorialHasBeenViewed
    }
    
    func markOnboardingTutorialViewed() {
        onboardingTutorialViewedCache.cacheOnboardingTutorialViewed()
    }
}
