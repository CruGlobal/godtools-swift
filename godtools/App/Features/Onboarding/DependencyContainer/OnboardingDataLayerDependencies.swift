//
//  OnboardingDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDataLayerDependencies: OnboardingDataLayerDependenciesInterface {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getOnboardingTutorialViewedRepository() -> OnboardingTutorialViewedRepositoryInterface {
        return OnboardingTutorialViewedRepository(
            cache: OnboardingTutorialViewedUserDefaultsCache(
                userDefaultsCache: coreDataLayer.getUserDefaultsCache()
            )
        )
    }
}
