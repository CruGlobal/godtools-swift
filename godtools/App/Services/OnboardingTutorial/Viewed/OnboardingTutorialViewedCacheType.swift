//
//  OnboardingTutorialViewedCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol OnboardingTutorialViewedCacheType {
    
    var onboardingTutorialHasBeenViewed: Bool { get }
    
    func cacheOnboardingTutorialViewed()
}
