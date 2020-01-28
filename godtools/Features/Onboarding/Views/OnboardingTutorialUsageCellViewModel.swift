//
//  OnboardingTutorialUsageCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialUsageCellViewModel {
    
    let message: String
    
    required init(item: OnboardingTutorialUsageItem) {
        message = item.message
    }
}
