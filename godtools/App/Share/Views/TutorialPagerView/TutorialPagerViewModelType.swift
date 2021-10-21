//
//  TutorialPagerViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 9/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TutorialPagerViewModelType {
   
    var tutorialItems: [TutorialItemType] { get }
    var pageCount: Int { get }
    var page: ObservableValue<Int> { get }
    var skipButtonTitle: String { get }
    var skipButtonHidden: ObservableValue<Bool> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    var continueButtonHidden: ObservableValue<Bool> { get }
    var customViewBuilder: CustomViewBuilderType? { get }
    var navigationStepForSkipTapped: FlowStep? { get }
    var navigationStepForContinueTapped: FlowStep? { get }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType
    func skipTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
}
