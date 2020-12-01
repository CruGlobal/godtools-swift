//
//  LearnToShareToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LearnToShareToolViewModelType {
    
    var continueTitle: String { get }
    var startTrainingTitle: String { get }
    var numberOfLearnToShareToolItems: ObservableValue<Int> { get }
    
    func closeTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
    func willDisplayLearnToShareToolPage(index: Int) -> LearnToShareToolCellViewModelType
}
