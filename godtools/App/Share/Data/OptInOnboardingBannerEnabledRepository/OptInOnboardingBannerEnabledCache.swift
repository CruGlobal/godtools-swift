//
//  OptInOnboardingBannerEnabledCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class OptInOnboardingBannerEnabledCache: UserDefaults {
    
    private let enabledCacheKey: String = "keyOpenTutorialCalloutDisabled"
    
    @objc private var isEnabled: Bool {
        return bool(forKey: enabledCacheKey)
    }
    
    func getEnabled() -> NSObject.KeyValueObservingPublisher<OptInOnboardingBannerEnabledCache, Bool> {
        
        return publisher(for: \.isEnabled)
    }
    
    func storeEnabled(enabled: Bool) {
        
        super.set(enabled, forKey: enabledCacheKey)
        super.synchronize()
    }
}
