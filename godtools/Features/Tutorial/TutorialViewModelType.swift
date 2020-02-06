//
//  TutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialViewModelType {
    
    var hidesBackButton: ObservableValue<Bool> { get }
    var tutorialItems: ObservableValue<[TutorialItem]> { get }
    var currentTutorialItemIndex: ObservableValue<Int> { get }
    var currentPage: ObservableValue<Int> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    
    func closeTapped()
    func pageTapped(page: Int)
    func didScrollToPage(page: Int)
    func backTapped()
    func continueTapped()
    func tutorialVideoPlayTapped()
}
