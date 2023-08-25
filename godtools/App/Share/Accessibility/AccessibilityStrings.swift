//
//  AccessibilityStrings.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccessibilityStrings {
    
    enum Screen: String {
        
        var id: String {
            return rawValue
        }
        
        case onboardingTutorial = "Onboarding Tutorial Screen"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Screen"
    }
    
    enum Button: String {
        
        var id: String {
            return rawValue
        }
        
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Button"
    }
}
