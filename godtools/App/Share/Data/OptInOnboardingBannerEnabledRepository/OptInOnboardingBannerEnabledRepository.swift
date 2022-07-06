//
//  OptInOnboardingBannerEnabledRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class OptInOnboardingBannerEnabledRepository {
    
    func getBannerIsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultKeys.optInOnboardingBannerDisabled)
    }
}
