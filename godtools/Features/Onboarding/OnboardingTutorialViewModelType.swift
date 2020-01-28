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
    var skipButtonTitle: String { get }
    var continueButtonTitle: String { get }
    var showMoreButtonTitle: String { get }
    var getStartedButtonTitle: String { get }
    var hidesSkipButton: ObservableValue<Bool> { get }
    var hidesContinueButton: ObservableValue<Bool> { get }
    var hidesGetStartedButton: ObservableValue<Bool> { get }
    var hidesShowMoreButton: ObservableValue<Bool> { get }
    
    func skipTapped()
    func pageTapped(page: Int)
    func continueTapped()
    func showMoreTapped()
    func getStartedTapped()
}
