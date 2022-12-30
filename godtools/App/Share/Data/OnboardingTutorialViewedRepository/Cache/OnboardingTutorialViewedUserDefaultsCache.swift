//
//  OnboardingTutorialViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewedUserDefaultsCache {
        
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    private let onboardingTutorialViewedCacheKey: String = "keyOnboardingTutorialViewed"
    
    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    func getOnboardingTutorialViewed() -> Bool {
       
        guard let viewed = sharedUserDefaultsCache.getValue(key: onboardingTutorialViewedCacheKey) as? Bool else {
            return false
        }
        
        return viewed
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) {
        
        sharedUserDefaultsCache.cache(value: viewed, forKey: onboardingTutorialViewedCacheKey)
        sharedUserDefaultsCache.commitChanges()
    }
}
