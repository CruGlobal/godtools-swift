//
//  OnboardingTutorialProvider.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialProvider: OnboardingTutorialProviderType {
    
    let aboutTheAppItems: [MainOnboardingTutorialItem]
    let appUsageListItem: OnboardingTutorialUsageListItem
    
    required init(localizationServices: LocalizationServices) {
        
        aboutTheAppItems = [
            MainOnboardingTutorialItem(
                backgroundImageName: "onboarding_tutorial_background_0",
                backgroundCustomViewId: nil,
                imageName: nil,
                animationName: "onboarding_tutorial_cups",
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.aboutAppItem.0.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.aboutAppItem.0.message")
            ),
            MainOnboardingTutorialItem(
                backgroundImageName: "onboarding_tutorial_background_1",
                backgroundCustomViewId: nil,
                imageName: nil,
                animationName: "onboarding_tutorial_knife",
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.aboutAppItem.1.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.aboutAppItem.1.message")
            ),
            MainOnboardingTutorialItem(
                backgroundImageName: "onboarding_tutorial_background_2",
                backgroundCustomViewId: nil,
                imageName: nil,
                animationName: "onboarding_tutorial_rocket",
                title: localizationServices.stringForMainBundle(key: "onboardingTutorial.aboutAppItem.2.title"),
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.aboutAppItem.2.message")
            )
        ]
        
        appUsageListItem = OnboardingTutorialUsageListItem(
            backgroundImageName: nil,
            backgroundCustomViewId: "onboarding_tutorial_gradient_background",
            usageItems: [
            OnboardingTutorialUsageItem(
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.appUsageItem.0.message")
            ),
            OnboardingTutorialUsageItem(
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.appUsageItem.1.message")
            ),
            OnboardingTutorialUsageItem(
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.appUsageItem.2.message")
            ),
            OnboardingTutorialUsageItem(
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.appUsageItem.3.message")
            ),
            OnboardingTutorialUsageItem(
                message: localizationServices.stringForMainBundle(key: "onboardingTutorial.appUsageItem.4.message")
            )]
        )
    }
}
