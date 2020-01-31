//
//  DisabledOnboardingTutorialServices.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DisabledOnboardingTutorialServices: OnboardingTutorialServicesType {
    
    private let disabled: Bool
    
    init(disabled: Bool) {
        self.disabled = disabled
    }
    
    var tutorialIsAvailable: Bool {
        return !disabled
    }
    
    func enableOnboardingTutorial() {

    }
    
    func disableOnboardingTutorial() {

    }
}
