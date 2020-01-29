//
//  FlowStep.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum FlowStep {
    
    // onboarding
    case beginTappedFromOnboardingWelcome
    case skipTappedFromOnboardingTutorial
    case showMoreTappedFromOnboardingTutorial
    case getStartedTappedFromOnboardingTutorial
    
    // home
    case openTutorialTapped
    
    // tutorial
    case closeTappedFromTutorial
    case startUsingGodToolsTappedFromTutorial
}
