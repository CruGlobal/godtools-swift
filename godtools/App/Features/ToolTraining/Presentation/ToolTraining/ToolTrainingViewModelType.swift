//
//  ToolTrainingViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolTrainingViewModelType {
    
    var progress: ObservableValue<AnimatableValue<CGFloat>> { get }
    var trainingTipBackgroundImage: ObservableValue<UIImage?> { get }
    var trainingTipForegroundImage: ObservableValue<UIImage?> { get }
    var title: ObservableValue<String> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    var numberOfTipPages: ObservableValue<Int> { get }
    
    func viewLoaded()
    func overlayTapped()
    func closeTapped()
    func continueTapped()
    func buttonWithUrlTapped(url: String)
    func tipPageWillAppear(page: Int, window: UIViewController, safeArea: UIEdgeInsets) -> MobileContentView?
    func tipPageDidChange(page: Int)
    func tipPageDidAppear(page: Int)
}
