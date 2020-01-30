//
//  DisabledOnboardingTutorialServices.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DisabledOnboardingTutorialServices: OnboardingTutorialServicesType {
    
    var tutorialIsAvailable: Bool {
        return false
    }
    
    func enableOnboardingTutorial() {
        // Required for protocol.  Nothing needed here.
    }
    
    func disableOnboardingTutorial() {
        // Required for protocol.  Nothing needed here.
    }
}
