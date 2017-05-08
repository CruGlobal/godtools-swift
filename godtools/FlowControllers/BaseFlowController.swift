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
        if viewController.isKind(of: BaseViewController.self) {
            (viewController as! BaseViewController).baseDelegate = self
        }
        self.currentViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Navigation Controller Delegate
    
    // MARK: - Helpers
    
    func configureNavigation(navigationController: UINavigationController) {
        configureNavigationColor(navigationController: navigationController, color: .gtBlue)
        navigationController.delegate = self
    }
    
    func resetNavigationControllerColorToDefault() {
        let navigationController: UINavigationController = (self.currentViewController?.navigationController)!
        configureNavigationColor(navigationController: navigationController, color: .gtBlue)
    }
    
    func configureNavigationColor(navigationController: UINavigationController, color: UIColor) {
        navigationController.navigationBar.tintColor = .gtWhite
        navigationController.navigationBar.barTintColor = color
        navigationController.navigationBar.isOpaque = true
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gtWhite,
                                                                  NSFontAttributeName: UIFont.gtSemiBold(size: 17.0)]
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayMenu),
                                               name: .displayMenuNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissMenu),
                                               name: .dismissMenuNotification,
                                               object: nil)
    }
    
    func displayMenu() {
        let menuViewController = MenuViewController(nibName: String(describing:MenuViewController.self), bundle: nil)
        let navigationController = self.currentViewController?.navigationController
        let src = self.currentViewController
        let dst = menuViewController
        let srcViewWidth = src?.view.frame.size.width
        
        src?.view.superview?.insertSubview(dst.view, aboveSubview: (src!.view)!)
        dst.view.transform = CGAffineTransform(translationX: -(srcViewWidth!), y: 64)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        src?.view.transform = CGAffineTransform(translationX: srcViewWidth!, y: 0)
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 64) },
                       completion: { finished in
                        navigationController?.pushViewController(dst, animated: false) } )
    }
    
    func dismissMenu() {
        let navigationController = self.currentViewController?.navigationController
        let menuViewController = navigationController?.topViewController as! MenuViewController
        let src = menuViewController
        let dst = self.currentViewController
        let dstViewWidth = dst?.view.frame.size.width
        
        src.view.superview?.insertSubview(dst!.view, aboveSubview: (src.view)!)
        dst?.view.transform = CGAffineTransform(translationX: dstViewWidth!, y: 0)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        src.view.transform = CGAffineTransform(translationX: -(dstViewWidth!), y: 64)
                        dst?.view.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: { finished in
                        _ = navigationController?.popViewController(animated: false) } )
    }
    
}

extension BaseFlowController: BaseViewControllerDelegate {
    
    func goBack() {
        _ = self.currentViewController?.navigationController?.popViewController(animated: true)
        resetNavigationControllerColorToDefault()
    }
    
    func changeNavigationBarColor(_ color: UIColor) {
        let navigationController: UINavigationController = (self.currentViewController?.navigationController)!
        configureNavigationColor(navigationController: navigationController, color: color)
    }
    
}
