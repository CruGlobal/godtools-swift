//
//  TutorialPagerViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 9/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TutorialPagerViewModelType: TutorialPagerAnalyticsType {
   
    var pageCount: Int { get }
    var page: ObservableValue<Int> { get }
    var skipButtonTitle: String { get }
    var skipButtonHidden: ObservableValue<Bool> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    var footerHidden: ObservableValue<Bool> { get }

    func tutorialItemWillAppear(index: Int) -> TutorialPagerCellViewModelType
    func skipTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
    func tutorialVideoPlayTapped()
}
