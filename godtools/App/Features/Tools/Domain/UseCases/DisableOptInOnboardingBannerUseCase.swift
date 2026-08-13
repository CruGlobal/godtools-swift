//
//  DisableOptInOnboardingBannerUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class DisableOptInOnboardingBannerUseCase: Sendable {
    
    private let optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository
    
    init(optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository) {
        self.optInOnboardingBannerEnabledRepository = optInOnboardingBannerEnabledRepository
    }
    
    func execute() {
        optInOnboardingBannerEnabledRepository
            .storeEnabled(enabled: false)
    }
}
