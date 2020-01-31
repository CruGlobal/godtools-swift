//
//  OnboardingTutorialBackgroundItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol OnboardingTutorialBackgroundItem {
    var backgroundImageName: String? { get }
    var backgroundCustomViewId: String? { get }
}
