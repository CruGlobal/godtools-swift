//
//  OnboardingQuickStartCellViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartCellViewModel: OnboardingQuickStartCellViewModelType {
    
    let title: String
    let linkButtonTitle: String
    
    required init (item: OnboardingQuickStartItem) {
        
        title = item.title
        linkButtonTitle = item.linkButtonTitle
    }
}
