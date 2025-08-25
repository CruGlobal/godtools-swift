//
//  OnboardingTutorialViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewedUserDefaultsCache {
        
    private let userDefaultsCache: UserDefaultsCacheInterface
    private let onboardingTutorialViewedCacheKey: String = "keyOnboardingTutorialViewed"
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    func getOnboardingTutorialViewed() -> Bool {
       
        guard let viewed = userDefaultsCache.getValue(key: onboardingTutorialViewedCacheKey) as? Bool else {
            return false
        }
        
        return viewed
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) {
        
        userDefaultsCache.cache(value: viewed, forKey: onboardingTutorialViewedCacheKey)
        userDefaultsCache.commitChanges()
    }
}
