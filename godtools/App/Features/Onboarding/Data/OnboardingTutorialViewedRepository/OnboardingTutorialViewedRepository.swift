//
//  OnboardingTutorialViewedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class OnboardingTutorialViewedRepository: OnboardingTutorialViewedRepositoryInterface {
    
    private let cache: OnboardingTutorialViewedUserDefaultsCache
    
    init(cache: OnboardingTutorialViewedUserDefaultsCache) {
        
        self.cache = cache
    }
    
    func getOnboardingTutorialViewed() -> Bool {
       
        return cache.getOnboardingTutorialViewed()
    }
    
    func getOnboardingTutorialViewedPublisher() -> AnyPublisher<Bool, Never> {
        
        let cachedValue: Bool = cache.getOnboardingTutorialViewed()
        
        return Just(cachedValue)
            .eraseToAnyPublisher()
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) {
        
        cache.storeOnboardingTutorialViewed(viewed: viewed)
    }
}
