//
//  AnimatedView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Lottie

class AnimatedView: UIView {
    
    private var animationView: AnimationView?
    
    required init(frame: CGRect, animationName: String) {
                
        super.init(frame: frame)
        
        setAnimation(animationName: animationName)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    func setAnimation(animationName: String) {
        
        if let currentAnimationView = self.animationView {
            
            currentAnimationView.stop()
            currentAnimationView.removeFromSuperview()
            animationView = nil
            
            let viewConstraints: [NSLayoutConstraint] = constraints
            removeConstraints(viewConstraints)
        }
        
        let newAnimationView = AnimationView()
        
        newAnimationView.animation = Animation.named(animationName)
        newAnimationView.loopMode = .loop
        addSubview(newAnimationView)
        newAnimationView.constrainEdgesToSuperview()
        newAnimationView.play()
        
        self.animationView = newAnimationView
    }
}
