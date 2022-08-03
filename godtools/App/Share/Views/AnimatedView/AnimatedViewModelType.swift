//
//  AnimatedViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Lottie

protocol AnimatedViewModelType {

    var animationData: Animation? { get }
    var autoPlay: Bool { get }
    var loop: Bool { get }
    
    func getAssetSize() -> CGSize?
}
