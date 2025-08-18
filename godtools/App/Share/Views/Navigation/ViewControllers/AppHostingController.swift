//
//  AppHostingController.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class AppHostingController<Content: View>: UIHostingController<Content>, UIViewControllerTransitioningDelegate {
        
    private let navigationBar: AppNavigationBar?
    private let animateInAnimatedTransitioning: UIViewControllerAnimatedTransitioning?
    private let animateOutAnimatedTransitioning: UIViewControllerAnimatedTransitioning?
    
    init(rootView: Content, navigationBar: AppNavigationBar?, animateInAnimatedTransitioning: UIViewControllerAnimatedTransitioning? = nil, animateOutAnimatedTransitioning: UIViewControllerAnimatedTransitioning? = nil) {
        
        self.navigationBar = navigationBar
        self.animateInAnimatedTransitioning = animateInAnimatedTransitioning
        self.animateOutAnimatedTransitioning = animateOutAnimatedTransitioning
        
        super.init(rootView: rootView)
         
        if animateInAnimatedTransitioning != nil || animateOutAnimatedTransitioning != nil {
            transitioningDelegate = self
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        navigationBar?.willAppear(viewController: self, animated: animated)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return animateInAnimatedTransitioning
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return animateOutAnimatedTransitioning
    }
}
