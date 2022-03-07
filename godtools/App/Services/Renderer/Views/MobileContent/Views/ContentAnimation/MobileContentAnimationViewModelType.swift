//
//  MobileContentAnimationViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAnimationViewModelType {
    
    var animatedViewModel: AnimatedViewModelType? { get }
    
    func animationTapped()
}
