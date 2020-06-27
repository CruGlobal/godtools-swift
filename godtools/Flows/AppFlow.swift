//
//  AppFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI

class AppFlow: NSObject, FlowDelegate {
    
    private let viewsService: ViewsServiceType
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var toolsFlow: ToolsFlow?
    private var tutorialFlow: TutorialFlow?
    private var navigationStarted: Bool = false
    
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: UINavigationController
        
    init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
        self.viewsService = appDiContainer.viewsService
        
        super.init()
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = UIColor.white
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([LaunchView()], animated: false)
        
        rootController.addChildController(child: navigationController)
    }
    
    private func requestInitialData() {
        
        appDiContainer.initialDataDownloader.downloadData()
    }
    
    private func setupInitialNavigation() {
        
        if appDiContainer.onboardingTutorialAvailability.onboardingTutorialIsAvailable {
            navigate(step: .showOnboardingTutorial(animated: false))
        }
        else {
            navigate(step: .showTools(animated: true, shouldCreateNewInstance: true))
        }
    }
    
    func navigate(step: FlowStep) {

        switch step {
        
        case .showTools(let animated, let shouldCreateNewInstance):
            
            navigationController.setNavigationBarHidden(false, animated: false)

            configureNavigation(navigationController: navigationController)

            if shouldCreateNewInstance || toolsFlow == nil {

                requestInitialData()
                
                let toolsFlow: ToolsFlow = ToolsFlow(
                    flowDelegate: self,
                    appDiContainer: appDiContainer,
                    sharedNavigationController: navigationController
                )

                self.toolsFlow = toolsFlow

                if animated, let toolsView = toolsFlow.navigationController.viewControllers.first?.view {
                    toolsView.alpha = 0
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                        toolsView.alpha = 1
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
            
            navigate(step: .showTools(animated: false, shouldCreateNewInstance: false))
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
            
        case .showMenu:
            navigateToMenu(animated: true)
            
        case .doneTappedFromMenu:
            closeMenu(animated: true)
            
        case .showLanguageSettings:
            
            let languageSettingsFlow = LanguageSettingsFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController
            )
            
            self.languageSettingsFlow = languageSettingsFlow
                   
        case .homeTappedFromTract:
            _ = navigationController.popToRootViewController(animated: true)
            resetNavigationControllerColorToDefault()
            
        case .sendEmailTappedFromTract(let subject, let message, let isHtml):
            
            if MFMailComposeViewController.canSendMail() {
                
                let finishedSendingMail = CallbackHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let viewModel = MailViewModel(
                    toRecipients: [],
                    subject: subject,
                    message: message,
                    isHtml: isHtml,
                    finishedSendingMailHandler: finishedSendingMail
                )
                
                let view = MailView(viewModel: viewModel)
                
                navigationController.present(view, animated: true, completion: nil)
            }
            else {
                
                let handler = CallbackHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let title: String = "GodTools"
                let message: String = NSLocalizedString("error_can_not_send_email", comment: "")
                let acceptedTitle: String = NSLocalizedString("ok", comment: "")
                
                let viewModel = AlertMessageViewModel(
                    title: title,
                    message: message,
                    cancelTitle: nil,
                    acceptTitle: acceptedTitle,
                    acceptHandler: handler
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    private func dismissTutorial() {
        closeMenu(animated: true)
        navigate(step: .showTools(animated: false, shouldCreateNewInstance: false))
        navigationController.dismiss(animated: true, completion: nil)
        tutorialFlow = nil
    }
    
    private func navigateToMenu(animated: Bool) {
        
        let menuFlow: MenuFlow = MenuFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer
        )
        self.menuFlow = menuFlow
        
        rootController.addChildController(child: menuFlow.navigationController)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        
        if animated {
                        
            menuFlow.view.transform = CGAffineTransform(translationX: screenWidth * -1, y: 0)
                        
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                menuFlow.view.transform = CGAffineTransform(translationX: 0, y: 0)
                self?.navigationController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
            }, completion: nil)
        }
        else {
            
            menuFlow.view.transform = CGAffineTransform(translationX: 0, y: 0)
            navigationController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
        }
    }
    
    private func closeMenu(animated: Bool) {
                
        if let menuFlow = menuFlow {
                        
            let screenWidth: CGFloat = UIScreen.main.bounds.size.width
            
            menuFlow.view.transform = CGAffineTransform(translationX: 0, y: 0)
            navigationController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
            
            if animated {
                
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    menuFlow.view.transform = CGAffineTransform(translationX: screenWidth * -1, y: 0)
                    self?.navigationController.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: { [weak self] ( finished: Bool) in
                    menuFlow.navigationController.removeAsChildController()
                    self?.menuFlow = nil
                })
            }
            else {
                
                menuFlow.view.transform = CGAffineTransform(translationX: screenWidth * -1, y: 0)
                navigationController.view.transform = CGAffineTransform(translationX: 0, y: 0)
                menuFlow.navigationController.removeAsChildController()
                self.menuFlow = nil
            }
        }
    }
    
    func goToUniversalLinkedResource(_ resource: DownloadedResource, language: Language, page: Int, parallelLanguageCode: String? = nil) {
        
        // TODO: Implement universal linking.
        
        /*
        
        // TODO: Is this needed? ~Levi
        GTSettings.shared.parallelLanguageCode = parallelLanguageCode
        
        let parallelLanguage: Language?
        
        if let parallelLanguageCode = parallelLanguageCode {
            parallelLanguage = LanguagesManager().loadFromDisk(code: parallelLanguageCode)
        }
        else {
            parallelLanguage = nil
        }
                
        let viewModel = TractViewModel(
            flowDelegate: self,
            resource: resource,
            primaryLanguage: language,
            parallelLanguage: parallelLanguage,
            tractManager: appDiContainer.tractManager,
            viewsService: appDiContainer.viewsService,
            analytics: appDiContainer.analytics,
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            tractPage: page
        )
        
        let view = TractView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)*/
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
}

extension AppFlow: UIApplicationDelegate {
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        _ = viewsService.addFailedResourceViewsIfNeeded()
        
        if !navigationStarted {
            navigationStarted = true
            setupInitialNavigation()
        }
    }
}
