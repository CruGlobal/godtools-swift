//
//  OnboardingTutorialUsageListCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialUsageListCellViewModel {
    
    let usageListItem: OnboardingTutorialUsageListItem
    
    required init(usageListItem: OnboardingTutorialUsageListItem) {
        
        self.usageListItem = usageListItem
    }
}
