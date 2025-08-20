//
//  MockOnboardingDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class MockOnboardingDataLayerDependencies: OnboardingDataLayerDependenciesInterface {
    
    init() {
        
    }
    
    func getOnboardingTutorialViewedRepository() -> OnboardingTutorialViewedRepositoryInterface {
        
        return MockOnboardingTutorialViewedRepository(tutorialViewed: false)
    }
}
