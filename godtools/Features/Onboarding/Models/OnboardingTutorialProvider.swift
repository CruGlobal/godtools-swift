//
//  OnboardingTutorialProvider.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct OnboardingTutorialProvider: OnboardingTutorialProviderType {
    
    let aboutTheAppItems: [MainOnboardingTutorialItem]
    let appUsageListItem: OnboardingTutorialUsageListItem
    
    init() {
        
        aboutTheAppItems = [
            MainOnboardingTutorialItem(
                backgroundImageName: "onboarding_tutorial_background_0",
                backgroundCustomViewId: nil,
                imageName: "onboarding_tutorial_cups",
                title: NSLocalizedString("onboardingTutorial.aboutAppItem.0.title", comment: ""),
                message: NSLocalizedString("onboardingTutorial.aboutAppItem.0.message", comment: "")
            ),
            MainOnboardingTutorialItem(
                backgroundImageName: "onboarding_tutorial_background_1",
                backgroundCustomViewId: nil,
                imageName: "onboarding_tutorial_knife",
                title: NSLocalizedString("onboardingTutorial.aboutAppItem.1.title", comment: ""),
                message: NSLocalizedString("onboardingTutorial.aboutAppItem.1.message", comment: "")
            ),
            MainOnboardingTutorialItem(
                backgroundImageName: "onboarding_tutorial_background_2",
                backgroundCustomViewId: nil,
                imageName: "onboarding_tutorial_rocket",
                title: NSLocalizedString("onboardingTutorial.aboutAppItem.2.title", comment: ""),
                message: NSLocalizedString("onboardingTutorial.aboutAppItem.2.message", comment: "")
            )
        ]
        
        appUsageListItem = OnboardingTutorialUsageListItem(
            backgroundImageName: nil,
            backgroundCustomViewId: "onboarding_tutorial_gradient_background",
            usageItems: [
            OnboardingTutorialUsageItem(
                message: NSLocalizedString("onboardingTutorial.appUsageItem.0.message", comment: "")
            ),
            OnboardingTutorialUsageItem(
                message: NSLocalizedString("onboardingTutorial.appUsageItem.1.message", comment: "")
            ),
            OnboardingTutorialUsageItem(
                message: NSLocalizedString("onboardingTutorial.appUsageItem.2.message", comment: "")
            ),
            OnboardingTutorialUsageItem(
                message: NSLocalizedString("onboardingTutorial.appUsageItem.3.message", comment: "")
            ),
            OnboardingTutorialUsageItem(
                message: NSLocalizedString("onboardingTutorial.appUsageItem.4.message", comment: "")
            )]
        )
    }
}
