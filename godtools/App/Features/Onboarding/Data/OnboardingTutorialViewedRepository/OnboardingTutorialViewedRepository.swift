//
//  OnboardingTutorialViewedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class OnboardingTutorialViewedRepository: Sendable {
    
    private let cache: OnboardingTutorialViewedCache
    
    init(cache: OnboardingTutorialViewedCache) {
        
        self.cache = cache
    }
    
    func getOnboardingTutorialViewed() async -> Bool {
       
        return await cache.getOnboardingTutorialViewed()
    }
    
    func storeOnboardingTutorialViewed(viewed: Bool) async {
        
        await cache.storeOnboardingTutorialViewed(viewed: viewed)
    }
}
