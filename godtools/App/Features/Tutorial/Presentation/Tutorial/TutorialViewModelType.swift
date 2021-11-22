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
    var currentPage: ObservableValue<Int> { get }
    var numberOfPages: ObservableValue<Int> { get }
    var continueTitle: ObservableValue<String> { get }
    
    func tutorialPageWillAppear(index: Int) -> TutorialCellViewModelType
    func closeTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
}
