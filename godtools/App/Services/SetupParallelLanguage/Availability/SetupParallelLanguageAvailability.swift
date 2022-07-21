//
//  SetupParallelLanguageAvailability.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageAvailability: SetupParallelLanguageAvailabilityType {
    
    private let setupParallelLanguageViewedCache: SetupParallelLanguageViewedCacheType
    private let isNewUserCache: IsNewUserDefaultsCache
    
    required init(setupParallelLanguageViewedCache: SetupParallelLanguageViewedCacheType, isNewUserCache: IsNewUserDefaultsCache) {
                
        self.setupParallelLanguageViewedCache = setupParallelLanguageViewedCache
        self.isNewUserCache = isNewUserCache
    }
    
    var setupParallelLanguageIsAvailable: Bool {
        return isNewUserCache.isNewUser && !setupParallelLanguageViewedCache.setupParallelLanguageHasBeenViewed
    }
    
    func markSetupParallelLanguageViewed() {
        setupParallelLanguageViewedCache.cacheSetupParallelLanguageViewed()
    }
}
