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
    
    required init(title: String, buttonTitle: String) {
        
        self.title = title
        self.buttonTitle = buttonTitle
    }
}
