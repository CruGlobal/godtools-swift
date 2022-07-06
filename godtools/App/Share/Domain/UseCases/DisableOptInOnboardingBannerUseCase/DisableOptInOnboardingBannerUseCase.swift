//
//  DisableOptInOnboardingBannerUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation


class DisableOptInOnboardingBannerUseCase {
    
    let optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository
    
    init(optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository) {
        self.optInOnboardingBannerEnabledRepository = optInOnboardingBannerEnabledRepository
    }
    
    func disableOptInOnboardingBanner() {
        optInOnboardingBannerEnabledRepository.disableBanner()
    }
}
