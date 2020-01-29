//
//  GTBaseFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class BaseFlowController: NSObject, UINavigationControllerDelegate {
    
    let appDiContainer: AppDiContainer
    
    var currentViewController: UIViewController?
    var navigationController: UINavigationController? {
        return currentViewController?.navigationController
    }
    
    init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        
        super.init()
        
        currentViewController = initialViewController()
        let navigationController = UINavigationController.init(rootViewController: currentViewController!)
        configureNavigation(navigationController: navigationController)
        defineObservers()
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
        navigationController.navigationBar.barTintColor = .clear
        navigationController.navigationBar.setBackgroundImage(NavigationBarBackground.createFrom(color), for: .default)
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gtWhite,
                                                                  NSAttributedString.Key.font: UIFont.gtSemiBold(size: 17.0)]
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
    
    @objc func displayMenu(notification: Notification? = nil) {
        let menuViewController = MenuViewController(nibName: String(describing:MenuViewController.self), bundle: nil)
        
        if let menuNotification = notification {
            if let userInfo = menuNotification.userInfo as? [String: Any] {
                menuViewController.isComingFromLoginBanner = userInfo["isSentFromLoginBanner"] as? Bool ?? false
            }
        }
        menuViewController.delegate = self
        
        guard let navigationController = self.currentViewController?.navigationController else { return }
        let navBarHeight = (navigationController.navigationBar.intrinsicContentSize.height) + UIApplication.shared.statusBarFrame.height
        guard let currentFrame = self.currentViewController?.view.frame else { return }
        menuViewController.view.frame = CGRect(x: currentFrame.minX, y: currentFrame.minY + navBarHeight, width: currentFrame.width, height: currentFrame.height)
        
        guard let src = self.currentViewController else { return }
        let dst = menuViewController
        let srcViewWidth = src.view.frame.size.width
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -(srcViewWidth), y: 0)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        src.view.transform = CGAffineTransform(translationX: srcViewWidth, y: 0)
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: { finished in
                        navigationController.pushViewController(dst, animated: false) } )
    }
    
    @objc func dismissMenu() {
        let navigationController = self.currentViewController?.navigationController
        guard let menuViewController = navigationController?.topViewController as? MenuViewController else { return }
        let src = menuViewController
        guard let dst = self.currentViewController else { return }
        let dstViewWidth = dst.view.frame.size.width
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: (src.view))
        dst.view.transform = CGAffineTransform(translationX: dstViewWidth, y: 0)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        src.view.transform = CGAffineTransform(translationX: -(dstViewWidth), y: 0)
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: { finished in
                        _ = navigationController?.popViewController(animated: false) } )
    }
    
}

extension BaseFlowController: BaseViewControllerDelegate {
    
    func goHome() {
        _ = self.currentViewController?.navigationController?.popToRootViewController(animated: true)
        resetNavigationControllerColorToDefault()
    }
    
    func goBack() {
        _ = self.currentViewController?.navigationController?.popViewController(animated: true)
        resetNavigationControllerColorToDefault()
    }
    
    func changeNavigationBarColor(_ color: UIColor) {
        let navigationController: UINavigationController = (self.currentViewController?.navigationController)!
        configureNavigationColor(navigationController: navigationController, color: color)
    }
    
    func changeNavigationColors(backgroundColor: UIColor, controlColor: UIColor) {
        let navigationController: UINavigationController = (self.currentViewController?.navigationController)!
        
        configureNavigationColor(navigationController: navigationController, color: backgroundColor)
        navigationController.navigationBar.tintColor = controlColor
    }
}

extension BaseFlowController: MenuViewControllerDelegate {
    func moveToUpdateLanguageSettings() {
        let viewController = LanguageSettingsViewController(nibName: String(describing:LanguageSettingsViewController.self), bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToAbout() {
        let viewController = AboutViewController(nibName: String(describing:AboutViewController.self), bundle: nil)
        self.pushViewController(viewController: viewController)
    }
    
    func openWebView(url: URL, title: String, analyticsTitle: String) {
        let viewController = WKWebViewController.create()
        viewController.websiteUrl = url
        viewController.pageTitle = title
        viewController.pageTitleForAnalytics = analyticsTitle
        self.pushViewController(viewController: viewController)
    }
}

extension BaseFlowController: LanguageSettingsViewControllerDelegate {
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: String(describing:LanguagesTableViewController.self), bundle: nil)
        viewController.delegate = self
        viewController.selectingForPrimary = primaryLanguage
        self.pushViewController(viewController: viewController)
    }
}

extension BaseFlowController: LanguagesTableViewControllerDelegate {
    
}
