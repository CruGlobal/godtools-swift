//
//  OnboardingTutorialAvailability.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialAvailability: OnboardingTutorialAvailabilityType {
    
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType
    private let isNewUserCache: IsNewUserDefaultsCache
    
    required init(getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, onboardingTutorialViewedCache: OnboardingTutorialViewedCacheType, isNewUserCache: IsNewUserDefaultsCache) {
                
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.onboardingTutorialViewedCache = onboardingTutorialViewedCache
        self.isNewUserCache = isNewUserCache
    }
    
    var onboardingTutorialIsAvailable: Bool {
        return isNewUserCache.isNewUser && !onboardingTutorialViewedCache.onboardingTutorialHasBeenViewed && getTutorialIsAvailableUseCase.getTutorialIsAvailable()
    }
    
    func markOnboardingTutorialViewed() {
        onboardingTutorialViewedCache.cacheOnboardingTutorialViewed()
    }
}
