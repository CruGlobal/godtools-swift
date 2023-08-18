//
//  FadeAnimationTransition.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class FadeAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Fade {
        case fadeIn
        case fadeOut
    }
        
    private let fade: FadeAnimationTransition.Fade
    private let duration: TimeInterval = 0.3
    
    init(fade: FadeAnimationTransition.Fade) {
        
        self.fade = fade
        
        super.init()
    }
        
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) {
            
            let containerView: UIView = transitionContext.containerView
            let fromView: UIView = fromViewController.view
            let toView: UIView = toViewController.view
                        
            switch (self.fade) {
            
            case .fadeIn:
                
                if toView.superview == nil {
                    containerView.addSubview(toView)
                    toView.translatesAutoresizingMaskIntoConstraints = false
                    toView.constrainEdgesToView(view: containerView)
                }
                
                toView.alpha = 0
                
                UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseOut, animations: {
                    
                    toView.alpha = 1
                    
                }, completion: { (finished: Bool) in
                    
                    transitionContext.completeTransition(finished)
                })
                
            case .fadeOut:
                
                UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseOut, animations: {
                    
                    fromView.alpha = 0
                    
                }, completion: { (finished: Bool) in
                    
                    transitionContext.completeTransition(finished)
                })
            }
        }
    }
}
