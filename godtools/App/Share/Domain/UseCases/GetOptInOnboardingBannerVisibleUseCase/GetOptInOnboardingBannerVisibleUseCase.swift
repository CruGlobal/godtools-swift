//
//  GetOptInOnboardingBannerVisibleUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOptInOnboardingBannerVisibleUseCase {
    
    private let getTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository
    
    required init(getTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository) {
        
        self.getTutorialAvailableUseCase = getTutorialAvailableUseCase
        self.optInOnboardingBannerEnabledRepository = optInOnboardingBannerEnabledRepository
    }
        
    func getBannerIsVisible() -> Bool {
        
        return getTutorialAvailableUseCase.getTutorialIsAvailable() &&
                optInOnboardingBannerEnabledRepository.getBannerIsEnabled()
    }
}
