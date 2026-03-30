//
//  OnboardingDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getOnboardingTutorialViewedRepository() -> OnboardingTutorialViewedRepository {
        return OnboardingTutorialViewedRepository(
            cache: OnboardingTutorialViewedCache(
                userDefaultsCache: coreDataLayer.getUserDefaultsCache()
            )
        )
    }
}
