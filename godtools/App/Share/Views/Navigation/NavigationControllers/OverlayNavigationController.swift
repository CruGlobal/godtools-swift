//
//  OverlayNavigationController.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class OverlayNavigationController: AppNavigationController {
        
    private let overlayAlpha: CGFloat = 0.4
        
    init(rootView: UIViewController, hidesNavigationBar: Bool, navigationBarAppearance: AppNavigationBarAppearance?) {
        
        super.init(hidesNavigationBar: hidesNavigationBar, navigationBarAppearance: navigationBarAppearance)
        
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
        
        rootView.view.backgroundColor = .clear
        view.backgroundColor = UIColor.black.withAlphaComponent(overlayAlpha)
        
        setViewControllers([rootView], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension OverlayNavigationController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
                
        return FadeAnimationTransition(fade: .fadeIn)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
                
        return FadeAnimationTransition(fade: .fadeOut)
    }
}
