//
//  TutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialViewModelType {
    
    var tutorialItems: ObservableValue<[TutorialItem]> { get }
    var currentTutorialItemIndex: ObservableValue<Int> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    var moreInfoTitle: String { get }
    
    func pageTapped(page: Int)
    func continueTapped()
}
