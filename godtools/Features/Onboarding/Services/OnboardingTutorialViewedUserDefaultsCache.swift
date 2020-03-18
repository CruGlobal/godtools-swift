//
//  OnboardingTutorialViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct OnboardingTutorialViewedUserDefaultsCache: OnboardingTutorialViewedCacheType {
    
    private let keyOnboardingTutorialViewed: String = "keyOnboardingTutorialViewed"
        
    var onboardingTutorialHasBeenViewed: Bool {
        return getViewedValueFromCache() ?? false
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func getViewedValueFromCache() -> Bool? {
        return defaults.object(forKey: keyOnboardingTutorialViewed) as? Bool
    }
    
    func cacheOnboardingTutorialViewed() {
        defaults.set(true, forKey: keyOnboardingTutorialViewed)
        defaults.synchronize()
    }
}
