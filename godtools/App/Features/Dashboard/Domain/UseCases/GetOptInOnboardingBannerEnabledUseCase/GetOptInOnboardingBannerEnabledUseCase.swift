//
//  GetOptInOnboardingBannerEnabledUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOptInOnboardingBannerEnabledUseCase {
    
    private let getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase
    private let optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository
    
    required init(getOptInOnboardingTutorialAvailableUseCase: GetOptInOnboardingTutorialAvailableUseCase, optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository) {
        
        self.getOptInOnboardingTutorialAvailableUseCase = getOptInOnboardingTutorialAvailableUseCase
        self.optInOnboardingBannerEnabledRepository = optInOnboardingBannerEnabledRepository
    }
        
    func getBannerIsEnabled() -> AnyPublisher<Bool, Never> {
                
        return Publishers
            .CombineLatest(getOptInOnboardingTutorialAvailableUseCase.getOptInOnboardingTutorialIsAvailable(), optInOnboardingBannerEnabledRepository.getEnabled())
            .map { (tutorialAvailable: Bool, bannerEnabled: Bool) in
                                
                return tutorialAvailable && bannerEnabled
            }
            .eraseToAnyPublisher()
    }
}
