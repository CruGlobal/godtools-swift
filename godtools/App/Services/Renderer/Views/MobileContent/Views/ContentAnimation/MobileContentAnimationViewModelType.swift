//
//  MobileContentAnimationViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAnimationViewModelType {
    
    var animationJsonFilepath: String { get }
    var autoPlay: Bool { get }
    var loop: Bool { get }
}
