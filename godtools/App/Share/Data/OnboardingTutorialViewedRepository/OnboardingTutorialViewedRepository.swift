//
//  OnboardingTutorialViewedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewedRepository {
    
    private let cache: OnboardingTutorialViewedUserDefaultsCache
    
    init(cache: OnboardingTutorialViewedUserDefaultsCache) {
        
        self.cache = cache
    }
    
    func getOnboardingTutorialViewed() -> Bool {
       
        return cache.getOnboardingTutorialViewed()
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) {
        
        cache.storeOnboardingTutorialViewed(viewed: viewed)
    }
}
