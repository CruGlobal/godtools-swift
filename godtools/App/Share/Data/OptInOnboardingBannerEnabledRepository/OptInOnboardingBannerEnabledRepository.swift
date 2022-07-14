//
//  OptInOnboardingBannerEnabledRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class OptInOnboardingBannerEnabledRepository {
        
    private let cache: OptInOnboardingBannerEnabledCache
    
    init(cache: OptInOnboardingBannerEnabledCache) {
        
        self.cache = cache
    }
    
    func getEnabled() -> AnyPublisher<Bool, Never> {

        return cache.getEnabled()
    }
    
    func storeEnabled(enabled: Bool) {
        
        cache.storeEnabled(enabled: enabled)
    }
}
