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
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var toolsFlow: ToolsFlow?
    private var tutorialFlow: TutorialFlow?
    private var articlesFlow: ArticlesFlow?
    
    private var navigationStarted: Bool = false
    
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: UINavigationController
        
    init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
        
        super.init()
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = UIColor.white
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([LaunchView()], animated: false)
        
        rootController.addChildController(child: navigationController)
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
            
            // TODO: Eventually need to remove the old tools flow.  Everything within the useOldToolsFlow conditional. ~Levi
            let useOldToolsFlow: Bool = true
            
            if useOldToolsFlow {
                
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
                    
                    let masterView = MasterHomeViewController(viewModel: viewModel)

                    navigationController.setViewControllers([masterView], animated: false)
                    
                    if animated {
                        masterView.view.alpha = 0
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                            masterView.view.alpha = 1
                        }, completion: nil)
                    }
                }
            }
            else {
                
                navigationController.setNavigationBarHidden(false, animated: false)

                configureNavigation(navigationController: navigationController)

                if shouldCreateNewInstance || toolsFlow == nil {

                    let toolsFlow: ToolsFlow = ToolsFlow(
                        flowDelegate: self,
                        appDiContainer: appDiContainer,
                        sharedNavigationController:
                        navigationController
                    )

                    self.toolsFlow = toolsFlow

                    if animated, let toolsView = toolsFlow.navigationController.viewControllers.first?.view {
                        toolsView.alpha = 0
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                            toolsView.alpha = 1
                        }, completion: nil)
                    }
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
            
        case .urlLinkTappedFromToolDetail(let url):
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
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
            
        case .toolTappedFromMyTools(let resource):
            navigateToTool(resource: resource)
            
        case .toolInfoTappedFromMyTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .toolTappedFromFindTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .toolInfoTappedFromFindTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource)
                   
        // TODO: Would like to create a separate Flow for a Tracts. ~Levi
        case .homeTappedFromTract:
            _ = navigationController.popToRootViewController(animated: true)
            resetNavigationControllerColorToDefault()
            
        case .shareTappedFromTract(let resource, let language, let pageNumber):
            
            let viewModel = ShareToolViewModel(
                resource: resource,
                language: language,
                pageNumber: pageNumber,
                analytics: appDiContainer.analytics
            )
            
            let view = ShareToolView(viewModel: viewModel)
            
            navigationController.present(
                view.controller,
                animated: true,
                completion: nil
            )
            
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
                
                let handler = AlertMessageViewAcceptHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let title: String = "GodTools"
                let message: String = NSLocalizedString("error_can_not_send_email", comment: "")
                let acceptedTitle: String = NSLocalizedString("ok", comment: "")
                
                let viewModel = AlertMessageViewModel(
                    title: title,
                    message: message,
                    acceptActionTitle: acceptedTitle,
                    handler: handler
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    private func navigateToTool(resource: DownloadedResource) {
        
        switch resource.toolTypeEnum {
        
        case .article:
            
            // TODO: Need to fetch language from user's primary language settings. A primary language should never be null. ~Levi
            let languagesManager: LanguagesManager = appDiContainer.languagesManager
            var language: Language?
            if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
                language = primaryLanguage
            }
            else {
                language = languagesManager.loadFromDisk(code: "en")
            }
            
            let articlesFlow = ArticlesFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource,
                language: language!
            )
            
            self.articlesFlow = articlesFlow
        
        case .tract:
            
            // TODO: Need to fetch language from user's primary language settings. A primary language should never be null. ~Levi
            let languagesManager: LanguagesManager = appDiContainer.languagesManager
            var primaryLanguage: Language?
            if let settingsPrimaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
                primaryLanguage = settingsPrimaryLanguage
            }
            
            var resourceSupportsPrimaryLanguage: Bool = false
            for translation in resource.translations {
                if let code = translation.language?.code {
                    if code == primaryLanguage?.code {
                        resourceSupportsPrimaryLanguage = true
                        break
                    }
                }
            }
                        
            if primaryLanguage == nil || !resourceSupportsPrimaryLanguage {
                primaryLanguage = languagesManager.loadFromDisk(code: "en")
            }
            
            let parallelLanguage = languagesManager.loadParallelLanguageFromDisk()
            
            let viewModel = TractViewModel(
                flowDelegate: self,
                resource: resource,
                primaryLanguage: primaryLanguage!,
                parallelLanguage: parallelLanguage,
                tractManager: appDiContainer.tractManager,
                analytics: appDiContainer.analytics,
                toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
                tractPage: 0
            )
            let view = TractView(viewModel: viewModel)

            navigationController.pushViewController(view, animated: true)
        
        case .unknown:
            let viewModel = AlertMessageViewModel(title: "Internal Error", message: "Unknown tool type for resource.", acceptActionTitle: "OK", handler: nil)
            let view = AlertMessageView(viewModel: viewModel)
            navigationController.present(view.controller, animated: true, completion: nil)
        }
    }
    
    private func navigateToToolDetail(resource: DownloadedResource) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            analytics: appDiContainer.analytics,
            exitLinkAnalytics: appDiContainer.exitLinkAnalytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
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
            analytics: appDiContainer.analytics,
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            tractPage: page
        )
        
        let view = TractView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
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
        if !navigationStarted {
            navigationStarted = true
            setupInitialNavigation()
        }
    }
}
