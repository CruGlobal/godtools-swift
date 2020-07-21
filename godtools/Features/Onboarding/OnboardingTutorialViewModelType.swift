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
    var skipButtonTitle: String { get }
    var continueButtonTitle: String { get }
    var showMoreButtonTitle: String { get }
    var getStartedButtonTitle: String { get }
    
    func skipTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
    func showMoreTapped()
    func getStartedTapped()
}
