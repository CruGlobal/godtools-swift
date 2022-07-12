//
//  OptInOnboardingBannerEnabledCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class OptInOnboardingBannerEnabledCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    private let enabledCacheKey: String = "keyOpenTutorialCalloutDisabled"
    
    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    func getEnabled() -> Bool? {
        
        return sharedUserDefaultsCache.getValue(key: enabledCacheKey) as? Bool
    }
    
    func storeEnabled(enabled: Bool) {
        
        sharedUserDefaultsCache.cache(value: enabled, forKey: enabledCacheKey)
        sharedUserDefaultsCache.commitChanges()
    }
}
