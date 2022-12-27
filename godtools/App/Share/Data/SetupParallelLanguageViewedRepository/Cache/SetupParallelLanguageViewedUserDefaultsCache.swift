//
//  SetupParallelLanguageViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewedUserDefaultsCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    private let setupParallelLanguageViewedCacheKey: String = "keySetupParallelLanguageViewed"
    
    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    func getSetupParallelLanguageViewed() -> Bool? {
       
        return sharedUserDefaultsCache.getValue(key: setupParallelLanguageViewedCacheKey) as? Bool
    }
    
    func storeSetupParallelLanguageViewed(viewed: Bool) {
        
        sharedUserDefaultsCache.cache(value: viewed, forKey: setupParallelLanguageViewedCacheKey)
        sharedUserDefaultsCache.commitChanges()
    }
}
