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
        
    private static let sharedPublishers: OptInOnboardingBannerEnabledRepositoryPublishers = OptInOnboardingBannerEnabledRepositoryPublishers()
    
    private let cache: OptInOnboardingBannerEnabledCache
    private let publishers: OptInOnboardingBannerEnabledRepositoryPublishers
    
    init(cache: OptInOnboardingBannerEnabledCache) {
        
        self.cache = cache
        self.publishers = OptInOnboardingBannerEnabledRepository.sharedPublishers
        
        publishers.enabled.value = cache.getEnabled()
    }
    
    func getEnabled() -> AnyPublisher<Bool?, Never> {
                
        return publishers.enabled.eraseToAnyPublisher()
    }
    
    func storeEnabled(enabled: Bool) {
        
        cache.storeEnabled(enabled: enabled)
        
        publishers.enabled.send(enabled)
    }
}
