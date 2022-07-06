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
        return UserDefaults.standard.bool(forKey: userDefaultKey) == false
    }
    
    func disableBanner() {
        UserDefaults.standard.set(true, forKey: userDefaultKey)
    }
}
