//
//  OnboardingTutorialProvider.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialProvider: TutorialPagerProviderType {
    
    let tutorialItems: [TutorialPagerItem]
    
    required init(localizationServices: LocalizationServices) {
        
        tutorialItems = [
            /*TutorialPagerItem(
                title: "",
                message: "",
                continueButtonLabel: localizationServices.stringForMainBundle(key: "onboardingTutorial.beginButton.title"),
                imageName: nil,
                animationName: nil,
                youTubeVideoId: nil,
                customViewId: "onboarding-0",
                hideSkip: false,
                hideContinueButton: false,
                hidePageControl: false
            ),*/
            TutorialPagerItem(
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.1.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.1.message"),
                continueButtonLabel: localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title"),
                imageName: nil,
                animationName: "onboarding_tutorial_cups",
                youTubeVideoId: nil,
                customViewId: nil,
                hideSkip: true,
                hideContinueButton: false,
                hidePageControl: false
            ),
            TutorialPagerItem(
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.2.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.2.message"),
                continueButtonLabel: localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title"),
                imageName: nil,
                animationName: "onboarding_tutorial_knife",
                youTubeVideoId: nil,
                customViewId: nil,
                hideSkip: false,
                hideContinueButton: true,
                hidePageControl: false
            ),
            TutorialPagerItem(
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.3.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.3.message"),
                continueButtonLabel: localizationServices.stringForMainBundle(key: "onboardingTutorial.getStartedButton.title"),
                imageName: nil,
                animationName: "onboarding_tutorial_rocket",
                youTubeVideoId: nil,
                customViewId: nil,
                hideSkip: false,
                hideContinueButton: false,
                hidePageControl: true
            )
        ]
    }
}
