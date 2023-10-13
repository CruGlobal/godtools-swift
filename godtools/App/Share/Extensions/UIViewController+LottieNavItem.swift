//
//  UIViewController+LottieNavItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Lottie

extension UIViewController {
  
    func addAnimatedBarButtonItem(barPosition: BarButtonItemBarPosition, index: Int?, animationName: String) -> UIBarButtonItem {
        
        let animationView = LottieAnimationView()
        
        let animation = LottieAnimation.named(animationName)
        animationView.animation = animation
        
        animationView.loopMode = .loop
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()

        let item = UIBarButtonItem(customView: animationView)
        
        addBarButtonItem(item: item, barPosition: barPosition, index: index)

        return item
    }
}
