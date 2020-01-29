//
//  MainOnboardingTutorialItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MainOnboardingTutorialItem: OnboardingTutorialItem {
    
    let backgroundImageName: String?
    let backgroundCustomViewId: String?
    let imageName: String
    let title: String
    let message: String
}
