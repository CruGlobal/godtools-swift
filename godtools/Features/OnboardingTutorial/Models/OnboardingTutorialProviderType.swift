//
//  OnboardingTutorialProviderType.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol OnboardingTutorialProviderType {
    
    var aboutTheAppItems: [MainOnboardingTutorialItem] { get }
    var appUsageListItem: OnboardingTutorialUsageListItem { get }
}
