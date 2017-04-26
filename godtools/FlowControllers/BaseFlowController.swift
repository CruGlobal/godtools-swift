//
//  GTBaseFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class BaseFlowController: NSObject, UINavigationControllerDelegate {
    
    var currentViewController: UIViewController?
    
    init(window: UIWindow, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        super.init()
        self.currentViewController = self.initialViewController()
        let navigationController = UINavigationController.init(rootViewController: self.currentViewController!)
        self.configureNavigation(navigationController: navigationController)
        window.rootViewController = navigationController
        self.defineObservers()
    }
    
    func initialViewController() -> UIViewController {
        preconditionFailure("This method must be overridden")
    }
    
    func pushViewController(viewController: UIViewController) {
        self.currentViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Navigation Controller Delegate
    
    // MARK: - Helpers
    
    func configureNavigation(navigationController: UINavigationController) {
        navigationController.navigationBar.tintColor = .gtWhite
        navigationController.navigationBar.barTintColor = .gtBlue
        navigationController.navigationBar.isOpaque = true
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gtWhite,
                                                                  NSFontAttributeName: UIFont.gtSemiBold(size: 17.0)]
        
        navigationController.delegate = self
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayMenu),
                                               name: .displayMenuNotification,
                                               object: nil)
    }
    
    func displayMenu() {
        let menuViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)
        let navigationController = self.currentViewController?.navigationController
        let src = self.currentViewController
        let dst = menuViewController
        let dstViewWidth = dst.view.frame.size.width
        
        src?.view.superview?.insertSubview(dst.view, aboveSubview: (src?.view)!)
        dst.view.transform = CGAffineTransform(translationX: -(dstViewWidth), y: 64)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 64) },
                       completion: { finished in
                        navigationController?.pushViewController(dst, animated: false) } )
    }
    
}
