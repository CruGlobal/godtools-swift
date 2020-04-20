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
    private var languageSettingsFlow: LanguageSettingsFlow?
    
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
        
        if appDiContainer.onboardingTutorialAvailability.onboardingTutorialIsAvailable {
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
                
                let viewModel = MasterHomeViewModel(
                    flowDelegate: self,
                    tutorialAvailability: appDiContainer.tutorialAvailability,
                    openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
                    analytics: appDiContainer.analytics
                )
                
                let masterView = MasterHomeViewController(viewModel: viewModel, delegate: self)

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
    
        case .closeTappedFromTutorial:
            dismissTutorial()
            
        case .startUsingGodToolsTappedFromTutorial:
            dismissTutorial()
            
        case .urlLinkTappedFromToolDetail(let url):
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        case .menuTappedFromHome:
            displayMenu()
            
        case .languagesTappedFromHome:
            
            let languageSettingsFlow = LanguageSettingsFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController
            )
            
            self.languageSettingsFlow = languageSettingsFlow
                        
        default:
            break
        }
    }
    
    private func dismissTutorial() {
        dismissMenu()
        navigate(step: .showMasterView(animated: false, shouldCreateNewInstance: false))
        navigationController.dismiss(animated: true, completion: nil)
        tutorialFlow = nil
    }
    
    func goToUniversalLinkedResource(_ resource: DownloadedResource, language: Language, page: Int, parallelLanguageCode: String? = nil) {
        
        let viewModel = TractViewModel(
            appsFlyer: appDiContainer.appsFlyer
        )
        
        let viewController = TractViewController(viewModel: viewModel)
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
}

extension BaseFlowController: MasterHomeViewControllerDelegate, HomeViewControllerDelegate {
    
    func moveToToolDetail(resource: DownloadedResource) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            analytics: appDiContainer.analytics
        )
        let view = ToolDetailViewController(viewModel: viewModel)
        view.delegate = self
        
        self.pushViewController(viewController: view)
    }
    
    func moveToTract(resource: DownloadedResource) {
        
        let viewModel = TractViewModel(
            appsFlyer: appDiContainer.appsFlyer
        )
        
        let viewController = TractViewController(viewModel: viewModel)
        viewController.resource = resource
        pushViewController(viewController: viewController)
    }
    
    func moveToArticle(resource: DownloadedResource) {
        
        // TODO: Instantiate from Flow: navigate(step: FlowStep) ~Levi
        /*
        let viewModel = ArticleViewModel(
            articleManager: appDiContainer.articleManager,
            languageManager: appDiContainer.languagesManager,
            resource: resource,
            analytics: appDiContainer.analytics
        )
        let view = ArticleView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
        */
        
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
            let viewModel = AlertMessageViewModel(title: "Internal Error", message: "Unknown tool type for resource.", acceptActionTitle: "OK", handler: nil)
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
