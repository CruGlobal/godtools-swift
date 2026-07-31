//
//  OnboardingTutorialViewedCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class OnboardingTutorialViewedCache: Sendable {
        
    private let userDefaultsCache: UserDefaultsCacheInterface
    private let onboardingTutorialViewedCacheKey: String = "keyOnboardingTutorialViewed"
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    func getOnboardingTutorialViewed() async -> Bool {
       
        guard let viewed = await userDefaultsCache.getValue(key: onboardingTutorialViewedCacheKey) as? Bool else {
            return false
        }
        
        return viewed
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) async {
        
        await userDefaultsCache.cache(value: viewed, forKey: onboardingTutorialViewedCacheKey)
        await userDefaultsCache.commitChanges()
    }
}
