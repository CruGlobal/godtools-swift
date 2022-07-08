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
    
    private func getTutorialAvailable() -> AnyPublisher<Bool, Never> {
        
        return Just(getOptInOnboardingTutorialAvailableUseCase.getOptInOnboardingTutorialIsAvailable()).eraseToAnyPublisher()
    }
        
    func getBannerIsEnabled() -> AnyPublisher<Bool, Never> {
        
        return Publishers
            .CombineLatest(getTutorialAvailable(), optInOnboardingBannerEnabledRepository.getEnabled())
            .allSatisfy { tutorialAvailable, bannerEnabled in
                return tutorialAvailable && bannerEnabled
            }
            .eraseToAnyPublisher()
    }
}
