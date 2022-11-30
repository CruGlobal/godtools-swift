//
//  MobileContentAnimationViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentAnimationViewModelType: ClickableMobileContentViewModel {
    
    var animatedViewModel: AnimatedViewModelType? { get }
    var animationEvents: [EventId] { get }
    var rendererState: State { get }
    
    func animationTapped()
}
