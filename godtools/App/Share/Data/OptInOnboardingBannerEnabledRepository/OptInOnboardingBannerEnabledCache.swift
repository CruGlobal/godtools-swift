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
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    func getEnabled() -> AnyPublisher<Bool, Never> {
        
        return userDefaults.publisher(for: \.enabled)
            .eraseToAnyPublisher()
    }
    
    func storeEnabled(enabled: Bool) {
        
        userDefaults.enabled = enabled
    }
}

extension UserDefaults {
    
    private static let enabledCacheKey: String = "keyOpenTutorialCalloutDisabled"
    
    @objc dynamic var enabled: Bool {
        get {
            
            if object(forKey: UserDefaults.enabledCacheKey) as? Bool == nil {
                return true
            }
            
            return bool(forKey: UserDefaults.enabledCacheKey)
        }
        set {
            set(newValue, forKey: UserDefaults.enabledCacheKey)
            synchronize()
        }
    }
}
