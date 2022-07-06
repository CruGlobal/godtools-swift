//
//  GetOptInOnboardingBannerVisibleUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOptInOnboardingBannerVisibleUseCase {
    
    private let getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository
    
    required init(getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository) {
        
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.optInOnboardingBannerEnabledRepository = optInOnboardingBannerEnabledRepository
    }
        
    func getBannerIsVisible() -> Bool {
        
        return getOptInOnboardingTutorialAvailableUseCase.getOptInOnboardingTutorialIsAvailable() &&
                optInOnboardingBannerEnabledRepository.getBannerIsEnabled()
    }
}
