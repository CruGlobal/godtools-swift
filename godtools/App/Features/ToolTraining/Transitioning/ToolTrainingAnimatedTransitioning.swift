//
//  ToolTrainingAnimatedTransitioning.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum AnimationType {
        case animateIn
        case animateOut
    }
    
    let animationType: AnimationType
    
    required init(animationType: AnimationType) {
        
        self.animationType = animationType
        
        super.init()
    }
    
    var animationDuration: TimeInterval {
        switch animationType {
        case .animateIn:
            return 0.35
        case .animateOut:
            return 0.24
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
                
        switch animationType {
        case .animateIn:
            
            guard let toolTrainingView = toViewController as? ToolTrainingView else {
                return
            }
            
            if toolTrainingView.view.superview == nil {
                let parentView: UIView = transitionContext.containerView
                parentView.addSubview(toolTrainingView.view)
                toolTrainingView.view.translatesAutoresizingMaskIntoConstraints = false
                toolTrainingView.view.constrainEdgesToView(view: parentView)
            }
            
            toolTrainingView.setViewState(viewState: .visible, animationDuration: animationDuration) { (finished: Bool) in
                transitionContext.completeTransition(finished)
            }
            
        case .animateOut:
            
            guard let toolTrainingView = fromViewController as? ToolTrainingView else {
                return
            }
            
            toolTrainingView.setViewState(viewState: .hidden, animationDuration: animationDuration) { (finished: Bool) in
                transitionContext.completeTransition(finished)
            }
        }
    }
}
