//
//  OnboardingWelcomeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingWelcomeViewModel: OnboardingWelcomeViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let logo: ObservableValue<UIImage?>
    let title: ObservableValue<String>
    let beginTitle: ObservableValue<String>
        
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
        
        logo = ObservableValue(value: UIImage(named: "onboarding_welcome_logo"))
        title = ObservableValue(value: NSLocalizedString("onboardingWelcome.titleLabel.welcome", comment: ""))
        beginTitle = ObservableValue(value: NSLocalizedString("onboardingWelcome.beginButton", comment: ""))
    }
    
    func changeTitleToTagline() {
        title.accept(value: NSLocalizedString("onboardingWelcome.titleLabel.tagline", comment: ""))
    }
    
    func beginTapped() {
        print("begin tapped")
        flowDelegate?.navigate(step: .beginTappedFromOnboardingWelcome)
    }
}
