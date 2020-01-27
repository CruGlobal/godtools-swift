//
//  OnboardingTutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol OnboardingTutorialViewModelType {
    
    var tutorialItems: ObservableValue<[OnboardingTutorialItem]> { get }
    var currentTutorialItemIndex: ObservableValue<Int> { get }
    var continueTitle: ObservableValue<String> { get }
    
    func skipTapped()
    func pageTapped(page: Int)
    func continueTapped()
}
