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
    
    func getEnabled() -> AnyPublisher<Bool, Never> {
        
        return UserDefaults.standard.publisher(for: \.enabled)
            .eraseToAnyPublisher()
    }
    
    func storeEnabled(enabled: Bool) {
        
        UserDefaults.standard.enabled = enabled
    }
}

private extension UserDefaults {
    
    private static let enabledCacheKey: String = "keyOpenTutorialCalloutDisabled"
    
    @objc dynamic var enabled: Bool {
        get {
            
            if UserDefaults.standard.object(forKey: UserDefaults.enabledCacheKey) as? Bool == nil {
                return true
            }
            
            return UserDefaults.standard.bool(forKey: UserDefaults.enabledCacheKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.enabledCacheKey)
            UserDefaults.standard.synchronize()
        }
    }
}
