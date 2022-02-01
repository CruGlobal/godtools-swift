//
//  SetupParallelLanguageViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewedUserDefaultsCache: SetupParallelLanguageViewedCacheType {
    
    var setupParallelLanguageHasBeenViewed: Bool {
        return getViewedValueFromCache() ?? false
    }
    
    private var keySetupParallelLanguageViewed: String {
        return "keySetupParallelLanguageViewed"
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func getViewedValueFromCache() -> Bool? {
        return defaults.object(forKey: keySetupParallelLanguageViewed) as? Bool
    }
    
    func cacheSetupParallelLanguageViewed() {
        defaults.set(true, forKey: keySetupParallelLanguageViewed)
        defaults.synchronize()
    }
}
