//
//  OnboardingWelcomeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingWelcomeViewModel: OnboardingWelcomeViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    let logo: ObservableValue<UIImage?>
    let title: ObservableValue<String>
    let beginTitle: ObservableValue<String>
        
    required init(flowDelegate: FlowDelegate, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        
        logo = ObservableValue(value: UIImage(named: "onboarding_welcome_logo"))
        title = ObservableValue(value: NSLocalizedString("onboardingWelcome.titleLabel.welcome", comment: ""))
        beginTitle = ObservableValue(value: NSLocalizedString("onboardingWelcome.beginButton", comment: ""))
    }
    
    func pageViewed() {
        analytics.recordScreenView(
            screenName: "onboarding-1",
            siteSection: "onboarding",
            siteSubSection: ""
        )
    }
    
    func changeTitleToTagline() {
        title.accept(value: NSLocalizedString("onboardingWelcome.titleLabel.tagline", comment: ""))
    }
    
    func beginTapped() {
        flowDelegate?.navigate(step: .beginTappedFromOnboardingWelcome)
    }
}
