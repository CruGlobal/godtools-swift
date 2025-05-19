//
//  FadeAnimationTransition.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class FadeAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let defaultDuration: TimeInterval = 0.3
    
    enum Fade {
        case fadeIn
        case fadeOut
    }
        
    private let fade: FadeAnimationTransition.Fade
    private let duration: TimeInterval
    private let fadeOutAlpha: CGFloat
    private let fadeInAlpha: CGFloat
    
    init(fade: FadeAnimationTransition.Fade, duration: TimeInterval = FadeAnimationTransition.defaultDuration, fadeOutAlpha: CGFloat = 0, fadeInAlpha: CGFloat = 1) {
        
        self.fade = fade
        self.duration = duration
        self.fadeOutAlpha = fadeOutAlpha
        self.fadeInAlpha = fadeInAlpha
        
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
                                   
            switch fade {
            
            case .fadeIn:
                
                if toView.superview == nil {
                    containerView.addSubview(toView)
                    toView.translatesAutoresizingMaskIntoConstraints = false
                    toView.constrainEdgesToView(view: containerView)
                }
                
                toView.alpha = fadeOutAlpha
                
                UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseOut, animations: {
                                        
                    toView.alpha = self.fadeInAlpha
                    
                }, completion: { (finished: Bool) in
                                        
                    transitionContext.completeTransition(finished)
                })
                
            case .fadeOut:
                
                UIView.animate(withDuration: self.duration, delay: 0, options: .curveEaseOut, animations: {
                                        
                    fromView.alpha = self.fadeOutAlpha
                    
                }, completion: { (finished: Bool) in
                                        
                    transitionContext.completeTransition(finished)
                })
            }
        }
    }
}
