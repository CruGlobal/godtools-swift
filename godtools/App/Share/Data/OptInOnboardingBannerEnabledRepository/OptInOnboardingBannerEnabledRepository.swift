//
//  OptInOnboardingBannerEnabledRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class OptInOnboardingBannerEnabledRepository {
    
    let userDefaultKey = UserDefaultKeys.optInOnboardingBannerDisabled
    
    func getBannerIsEnabled() -> Bool {
        return UserDefaults.standard.optInOnboardingBannerDisabled == false
    }
    
    func disableBanner() {
        UserDefaults.standard.optInOnboardingBannerDisabled = true
    }
}
