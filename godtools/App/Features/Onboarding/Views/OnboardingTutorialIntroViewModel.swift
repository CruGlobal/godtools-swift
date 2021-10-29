//
//  OnboardingTutorialIntroViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialIntroViewModel: OnboardingTutorialIntroViewModelType {

    let logoImage: UIImage?
    let title: String
    let videoLinkLabel: String

    required init(localizationServices: LocalizationServices) {
        
        logoImage = UIImage(named: "onboarding_welcome_logo")
        title = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.title")
        videoLinkLabel = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.videoLink.title")
    }
}
