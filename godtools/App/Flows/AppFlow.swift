//
//  AppFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI

class AppFlow: NSObject, AppFlowType {
    
    private let dataDownloader: InitialDataDownloader
    private let followUpsService: FollowUpsService
    private let viewsService: ViewsService
    private let deepLinkingService: DeepLinkingServiceType
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var toolsFlow: ToolsFlow?
    private var tutorialFlow: TutorialFlow?
    private var resignedActiveDate: Date?
    private var navigationStarted: Bool = false
    private var isObservingDeepLinking: Bool = false
    
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: UINavigationController
        
    init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
        self.dataDownloader = appDiContainer.initialDataDownloader
        self.followUpsService = appDiContainer.followUpsService
        self.viewsService = appDiContainer.viewsService
        self.deepLinkingService = appDiContainer.deepLinkingService
        
        super.init()
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = UIColor.white
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([], animated: false)
        
        rootController.addChildController(child: navigationController)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeDeepLinkingObservers()
    }
    
    func resetFlowToToolsFlow(animated: Bool) {
        configureNavigationBar()
        toolsFlow?.navigationController.popToRootViewController(animated: animated)
        toolsFlow?.resetToolsMenu()
        navigationController.popToRootViewController(animated: animated)
        closeMenu(animated: animated)
        navigationController.dismiss(animated: animated, completion: nil)
        menuFlow = nil
        languageSettingsFlow = nil
        tutorialFlow = nil
    }
    
    private func setupInitialNavigation() {
        
        if appDiContainer.onboardingTutorialAvailability.onboardingTutorialIsAvailable {
            navigate(step: .showOnboardingTutorial(animated: false))
        }
        else {
            navigate(step: .showTools(animated: true, shouldCreateNewInstance: true))
        }
        
        loadInitialData()
    }
    
    private func loadInitialData() {
        
        dataDownloader.downloadInitialData()
        
        _ = followUpsService.postFailedFollowUpsIfNeeded()
        
        _ = viewsService.postFailedResourceViewsIfNeeded()
    }
    
    private func addDeepLinkingObservers() {
        
        guard !isObservingDeepLinking else {
            return
        }
        
        isObservingDeepLinking = true
        
        deepLinkingService.completed.addObserver(self) { [weak self] (deepLinkingType: DeepLinkingType) in
            DispatchQueue.main.async { [weak self] in
                
                switch deepLinkingType {
                
                case .tool(let resource, let primaryLanguage, let parallelLanguage, let liveShareStream, let page):
                    if let toolsFlow = self?.toolsFlow {
                        self?.resetFlowToToolsFlow(animated: false)
                        DispatchQueue.main.async {
                            toolsFlow.navigateToTool(
                                resource: resource,
                                primaryLanguage: primaryLanguage,
                                parallelLanguage: parallelLanguage,
                                liveShareStream: liveShareStream,
                                trainingTipsEnabled: false,
                                page: page
                            )
                        }
                    }
                case .none:
                    break
                }
            }
        }
    }
    
    private func removeDeepLinkingObservers() {
        
        isObservingDeepLinking = false
        deepLinkingService.completed.removeObserver(self)
    }
    
    func navigate(step: FlowStep) {

        switch step {
        
        case .showTools(let animated, let shouldCreateNewInstance):
            
            navigationController.setNavigationBarHidden(false, animated: false)

            configureNavigationBar()

            if shouldCreateNewInstance || toolsFlow == nil {

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
                
                addDeepLinkingObservers()
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
                   
        case .homeTappedFromTool(let isScreenSharing):
            
            if isScreenSharing {
                
                let acceptHandler = CallbackHandler { [weak self] in
                    self?.closeTool()
                }
                
                let localizationServices: LocalizationServices = appDiContainer.localizationServices
                                
                let viewModel = AlertMessageViewModel(
                    title: nil,
                    message: localizationServices.stringForMainBundle(key: "exit_tract_remote_share_session.message"),
                    cancelTitle: localizationServices.stringForMainBundle(key: "no").uppercased(),
                    acceptTitle: localizationServices.stringForMainBundle(key: "yes").uppercased(),
                    acceptHandler: acceptHandler
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
            }
            else {
                
                closeTool()
            }
            
        default:
            break
        }
    }
    
    private func closeTool() {
        _ = navigationController.popToRootViewController(animated: true)
        configureNavigationBar()
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
                     
            menuFlow.navigationController.dismiss(animated: animated, completion: nil)
            
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
        
    // MARK: - Navigation Bar
    
    private func configureNavigationBar() {
                
        let fontService: FontService = appDiContainer.getFontService()
        let font: UIFont = fontService.getFont(size: 17, weight: .semibold)
        
        navigationController.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = ColorPalette.gtBlue.color
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        
        navigationController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: font
        ]
    }
}

extension AppFlow: UIApplicationDelegate {
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        if navigationStarted, let resignedActiveDate = resignedActiveDate {
            
            let currentDate: Date = Date()
            let elapsedTimeInSeconds: TimeInterval = currentDate.timeIntervalSince(resignedActiveDate)
            let elapsedTimeInMinutes: TimeInterval = elapsedTimeInSeconds / 60
            
            if elapsedTimeInMinutes >= 120 {

                let loadingView: UIView = UIView(frame: UIScreen.main.bounds)
                let loadingImage: UIImageView = UIImageView(frame: UIScreen.main.bounds)
                loadingView.addSubview(loadingImage)
                loadingImage.image = UIImage(named: "LaunchImage")
                loadingView.backgroundColor = .white
                application.keyWindow?.addSubview(loadingView)
                
                resetFlowToToolsFlow(animated: false)
                
                loadInitialData()
                
                UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
                    loadingView.alpha = 0
                }, completion: {(finished: Bool) in
                    loadingView.removeFromSuperview()
                })
            }
        }
        
        resignedActiveDate = nil
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if !navigationStarted {
            
            navigationStarted = true
            setupInitialNavigation()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
                
        resignedActiveDate = Date()
        
        appDiContainer.shortcutItemsService.reloadShortcutItems(application: application)
    }
}
