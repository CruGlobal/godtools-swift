//
//  UserDefaults+Values.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    @objc var optInOnboardingBannerDisabled: Bool {
        get {
            return bool(forKey: UserDefaultKeys.optInOnboardingBannerDisabled)
        }
        
        set {
            set(newValue, forKey: UserDefaultKeys.optInOnboardingBannerDisabled)
        }
    }
}
