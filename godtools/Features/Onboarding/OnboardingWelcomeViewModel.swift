//
//  OnboardingWelcomeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

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
    
    private var analyticsScreenName: String {
        return "onboarding-1"
    }
    
    func pageViewed() {
        
        analytics.recordScreenView(
            screenName: analyticsScreenName,
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
