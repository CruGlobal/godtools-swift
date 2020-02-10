//
//  GTBaseFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import TheKeyOAuthSwift

class BaseFlowController: NSObject, FlowDelegate {
    
    private var onboardingFlow: OnboardingFlow?
    private var tutorialFlow: TutorialFlow?
    private var menuFlow: MenuFlow?
    
    private var navigationStarted: Bool = false
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    var currentViewController: UIViewController?
    
    init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
        
        super.init()
        
        defineObservers()
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([LaunchView()], animated: false)
    }
    
    private func setupInitialNavigation() {
        
        if appDiContainer.onboardingTutorialServices.tutorialIsAvailable {
            navigate(step: .showOnboardingTutorial(animated: false))
        }
        else {
            navigate(step: .showMasterView(animated: true, shouldCreateNewInstance: true))
        }
    }
    
    func navigate(step: FlowStep) {

        switch step {
        
        case .showMasterView(let animated, let shouldCreateNewInstance):
            
            navigationController.setNavigationBarHidden(false, animated: false)
            
            configureNavigation(navigationController: navigationController)
            
            let currentMasterView: MasterHomeViewController? = navigationController.viewControllers.first as? MasterHomeViewController
            
            if shouldCreateNewInstance || currentMasterView == nil {
                
                let masterView = MasterHomeViewController(
                    flowDelegate: self,
                    delegate: self,
                    tutorialServices: appDiContainer.tutorialServices
                )
                
                navigationController.setViewControllers([masterView], animated: false)
                currentViewController = masterView
                
                if animated {
                    masterView.view.alpha = 0
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                        masterView.view.alpha = 1
                    }, completion: nil)
                }
            }
            
        case .showOnboardingTutorial(let animated):
            
            let onboardingFlow = OnboardingFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer
            )
            
            navigationController.present(onboardingFlow.navigationController, animated: animated, completion: nil)
            
            self.onboardingFlow = onboardingFlow
            
        case .dismissOnboardingTutorial:
            
            navigate(step: .showMasterView(animated: false, shouldCreateNewInstance: false))
            navigationController.dismiss(animated: true, completion: nil)
            onboardingFlow = nil
                            
        case .showMoreTappedFromOnboardingTutorial:
            
            let tutorialFlow = TutorialFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: onboardingFlow?.navigationController
            )
            
            self.tutorialFlow = tutorialFlow
            onboardingFlow = nil
                            
        case .openTutorialTapped:
            let tutorialFlow = TutorialFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: nil
            )
            navigationController.present(tutorialFlow.navigationController, animated: true, completion: nil)
            self.tutorialFlow = tutorialFlow
    
        case .dismissTutorial:
            
            navigate(step: .showMasterView(animated: false, shouldCreateNewInstance: false))
            navigationController.dismiss(animated: true, completion: nil)
            tutorialFlow = nil
            
        default:
            break
        }
    }
    
    func goToUniversalLinkedResource(_ resource: DownloadedResource, language: Language, page: Int, parallelLanguageCode: String? = nil) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        viewController.currentPage = page
        viewController.universalLinkLanguage = language
        viewController.arrivedByUniversalLink = true
        GTSettings.shared.parallelLanguageCode = parallelLanguageCode
        
        pushViewController(viewController: viewController)
    }
    
    func pushViewController(viewController: UIViewController) {
        if viewController.isKind(of: BaseViewController.self) {
            (viewController as! BaseViewController).baseDelegate = self
        }
        navigationController.pushViewController(viewController, animated: true)
    }
        
    // MARK: - Helpers
    
    func configureNavigation(navigationController: UINavigationController) {
        configureNavigationColor(navigationController: navigationController, color: .gtBlue)
    }
    
    func resetNavigationControllerColorToDefault() {
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
        
        let menuFlow: MenuFlow = MenuFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController
        )
        self.menuFlow = menuFlow
        
        let menuView: MenuView = menuFlow.menuView
        
        if let menuNotification = notification {
            if let userInfo = menuNotification.userInfo as? [String: Any] {
                menuView.isComingFromLoginBanner = userInfo["isSentFromLoginBanner"] as? Bool ?? false
            }
        }
        
        menuView.delegate = self
        
        let navBarHeight = (navigationController.navigationBar.intrinsicContentSize.height) + UIApplication.shared.statusBarFrame.height
        guard let currentFrame = currentViewController?.view.frame else { return }
        menuView.view.frame = CGRect(x: currentFrame.minX, y: currentFrame.minY + navBarHeight, width: currentFrame.width, height: currentFrame.height)
        
        guard let src = currentViewController else { return }
        let srcViewWidth = src.view.frame.size.width
        
        src.view.superview?.insertSubview(menuView.view, aboveSubview: src.view)
        menuView.view.transform = CGAffineTransform(translationX: -(srcViewWidth), y: 0)
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            src.view.transform = CGAffineTransform(translationX: srcViewWidth, y: 0)
            menuView.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },completion: { [weak self] finished in
            self?.navigationController.pushViewController(menuView, animated: false)
        })
    }
    
    @objc func dismissMenu() {
        guard let menuView = navigationController.topViewController as? MenuView else { return }
        guard let dst = currentViewController else { return }
        let dstViewWidth = dst.view.frame.size.width
        
        menuView.view.superview?.insertSubview(dst.view, aboveSubview: (menuView.view))
        dst.view.transform = CGAffineTransform(translationX: dstViewWidth, y: 0)
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
            menuView.view.transform = CGAffineTransform(translationX: -(dstViewWidth), y: 0)
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { [weak self] finished in
            self?.menuFlow = nil
            _ = self?.navigationController.popViewController(animated: false)
        })
    }
    
}

extension BaseFlowController: BaseViewControllerDelegate {
    
    func goHome() {
        _ = navigationController.popToRootViewController(animated: true)
        resetNavigationControllerColorToDefault()
    }
    
    func goBack() {
        _ = navigationController.popViewController(animated: true)
        resetNavigationControllerColorToDefault()
    }
    
    func changeNavigationBarColor(_ color: UIColor) {
        configureNavigationColor(navigationController: navigationController, color: color)
    }
    
    func changeNavigationColors(backgroundColor: UIColor, controlColor: UIColor) {
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

extension BaseFlowController: MasterHomeViewControllerDelegate, HomeViewControllerDelegate {
    
    func moveToToolDetail(resource: DownloadedResource) {
        let viewController = ToolDetailViewController(nibName: String(describing:ToolDetailViewController.self), bundle: nil)
        viewController.resource = resource
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToTract(resource: DownloadedResource) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        pushViewController(viewController: viewController)
    }
    
    func moveToArticle(resource: DownloadedResource) {
        let viewController = ArticleToolViewController.create()
        viewController.resource = resource
        pushViewController(viewController: viewController)
    }
}

extension BaseFlowController: ToolDetailViewControllerDelegate {
    func openToolTapped(toolDetail: ToolDetailViewController, resource: DownloadedResource) {
        
        switch resource.toolTypeEnum {
        case .article:
            moveToArticle(resource: resource)
        case .tract:
            moveToTract(resource: resource)
        case .unknown:
            let viewModel = AlertMessageViewModel(title: "Internal Error", message: "Unknown tractType for resource.", acceptActionTitle: "OK", handler: nil)
            let view = AlertMessageView(viewModel: viewModel)
            navigationController.present(view.controller, animated: true, completion: nil)
        }
    }
}

extension BaseFlowController: UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        if !navigationStarted {
            navigationStarted = true
            setupInitialNavigation()
        }
    }
}
