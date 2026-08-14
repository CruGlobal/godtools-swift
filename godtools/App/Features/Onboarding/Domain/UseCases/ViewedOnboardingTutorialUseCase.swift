//
//  ViewedOnboardingTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ViewedOnboardingTutorialUseCase: Sendable {
    
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    
    init(onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository) {
        
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
    }
    
    func execute() async {
        
        await onboardingTutorialViewedRepository
            .storeOnboardingTutorialViewed(viewed: true)
    }
}
