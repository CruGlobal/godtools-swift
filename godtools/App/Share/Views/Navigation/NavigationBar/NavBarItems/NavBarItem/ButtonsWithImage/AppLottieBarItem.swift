//
//  AppLottieBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit
import Combine
import Lottie

class AppLottieBarItem: NavBarItem {
    
    init(animationName: String, color: UIColor?, target: AnyObject?, action: Selector?, accessibilityIdentifier: String?, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        let animationView = LottieAnimationView()
        
        let animation = LottieAnimation.named(animationName)
        animationView.animation = animation
        
        animationView.loopMode = .loop
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        
        super.init(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .custom(value: animationView),
                style: nil,
                color: color,
                target: target,
                action: action,
                accessibilityIdentifier: accessibilityIdentifier
            ),
            hidesBarItemPublisher: hidesBarItemPublisher
        )
    }
}

