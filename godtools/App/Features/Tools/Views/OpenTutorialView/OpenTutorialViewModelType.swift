//
//  OpenTutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol OpenTutorialViewModelType {
    
    var showTutorialTitle: String { get }
    var openTutorialTitle: String { get }
    var hidesOpenTutorial: ObservableValue<AnimatableValue<Bool>> { get }
    
    func openTutorialTapped()
    func closeTapped()
}
