//
//  OnboardingQuickStartCellViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartCellViewModel: OnboardingQuickStartCellViewModelType {
    
    let title: String
    let buttonTitle: String
    let dismissOnboardingTutorialType: OnboardingQuickStartView.DismissOnboardingTutorialType
    
    
    required init(title: String, buttonTitle: String, dismissOnboardingTutorialType: OnboardingQuickStartView.DismissOnboardingTutorialType) {
        
        self.title = title
        self.buttonTitle = buttonTitle
        self.dismissOnboardingTutorialType = dismissOnboardingTutorialType
    }
}
