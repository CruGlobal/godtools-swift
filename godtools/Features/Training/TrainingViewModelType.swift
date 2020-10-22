//
//  TrainingViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol TrainingViewModelType {
    
    var progress: ObservableValue<AnimatableValue<CGFloat>> { get }
    var icon: ObservableValue<UIImage?> { get }
    var title: ObservableValue<String> { get }
    var numberOfTipPages: ObservableValue<Int> { get }
    
    func overlayTapped()
    func closeTapped()
    func continueTapped()
}
