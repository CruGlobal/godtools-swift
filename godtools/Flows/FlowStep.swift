//
//  FlowStep.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum FlowStep {
    
    // app
    case showMasterView(animated: Bool, shouldCreateNewInstance: Bool)
    case showOnboardingTutorial(animated: Bool)
    case dismissOnboardingTutorial
    case dismissTutorial
    case urlLinkTappedFromToolDetail(url: URL)
    
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
    
    // menu
    case tutorialTappedFromMenu
    case myAccountTappedFromMenu
    case helpTappedFromMenu
    case contactUsTappedFromMenu
    case shareAStoryWithUsTappedFromMenu
    case termsOfUseTappedFromMenu
    case privacyPolicyTappedFromMenu
    case copyrightInfoTappedFromMenu
}
