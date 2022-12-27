//
//  OnboardingTutorialItemsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialItemsRepository {
    
    let tutorialItems: [OnboardingTutorialItem]
    
    required init(localizationServices: LocalizationServices) {
        
        tutorialItems = [
            OnboardingTutorialItem(
                title: "",
                message: "",
                imageName: nil,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: "onboarding-0"
            ),
            OnboardingTutorialItem(
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.1.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.1.message"),
                imageName: nil,
                animationName: "onboarding_two_dudes",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            OnboardingTutorialItem(
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.2.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.2.message"),
                imageName: nil,
                animationName: "onboarding_dog",
                youTubeVideoId: nil,
                customViewId: nil
            ),
            OnboardingTutorialItem(
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.3.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.3.message"),
                imageName: nil,
                animationName: "onboarding_distance",
                youTubeVideoId: nil,
                customViewId: nil
            ),
        ]
    }
}
