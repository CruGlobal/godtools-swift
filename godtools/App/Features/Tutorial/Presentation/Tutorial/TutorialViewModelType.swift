//
//  TutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialViewModelType {
    
    var numberOfTutorialItems: ObservableValue<Int> { get }
    var continueTitle: String { get }
    var startUsingGodToolsTitle: String { get }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType
    func closeTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
}
