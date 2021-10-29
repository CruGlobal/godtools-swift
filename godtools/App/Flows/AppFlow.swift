//
//  AppFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI

class AppFlow: NSObject, Flow {
    
    private let window: UIWindow
    private let dataDownloader: InitialDataDownloader
    private let followUpsService: FollowUpsService
    private let viewsService: ViewsService
    private let deepLinkingService: DeepLinkingServiceType
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var toolsFlow: ToolsFlow?
    private var tutorialFlow: TutorialFlow?
    private var articleDeepLinkFlow: ArticleDeepLinkFlow?
    private var resignedActiveDate: Date?
    private var navigationStarted: Bool = false
    private var observersAdded: Bool = false
    private var appIsInBackground: Bool = false
    private var isObservingDeepLinking: Bool = false
    
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: UINavigationController
        
    init(appDiContainer: AppDiContainer, window: UIWindow, appDeepLinkingService: DeepLinkingServiceType) {
        
        self.appDiContainer = appDiContainer
        self.window = window
        self.navigationController = UINavigationController()
        self.dataDownloader = appDiContainer.initialDataDownloader
        self.followUpsService = appDiContainer.followUpsService
        self.viewsService = appDiContainer.viewsService
        self.deepLinkingService = appDeepLinkingService
        
        super.init()
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = UIColor.white
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([], animated: false)
        
        rootController.addChildController(child: navigationController)
        
        addObservers()
        
        appDiContainer.firebaseInAppMessaging.setDelegate(delegate: self)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeObservers()
        removeDeepLinkingObservers()
    }
    
    private func addObservers() {
              
        guard !observersAdded else {
            return
        }
        observersAdded = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func removeObservers() {
        
        guard observersAdded else {
            return
        }
        observersAdded = false
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func resetFlowToToolsFlow(startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView?) {

        closeMenu(animated: false)
        navigationController.dismiss(animated: false, completion: nil)
        navigationController.setViewControllers([], animated: false)
        
        toolsFlow = nil
        onboardingFlow = nil
        menuFlow = nil
        languageSettingsFlow = nil
        articleDeepLinkFlow = nil
        tutorialFlow = nil
        
        navigate(step: .showTools(animated: false, shouldCreateNewInstance: true, startingToolbarItem: startingToolbarItem))
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
        
        deepLinkingService.deepLinkObserver.addObserver(self) { [weak self] (optionalDeepLink: ParsedDeepLinkType?) in
            guard let deepLink = optionalDeepLink else {
                return
            }
            self?.navigate(step: .deepLink(deepLinkType: deepLink))
        }
    }
    
    private func removeDeepLinkingObservers() {
        
        isObservingDeepLinking = false
        deepLinkingService.deepLinkObserver.removeObserver(self)
    }
    
    func navigate(step: FlowStep) {

        switch step {
        
        case .appLaunchedFromTerminatedState:
           
            if appDiContainer.onboardingTutorialAvailability.onboardingTutorialIsAvailable {
                
                navigate(step: .showOnboardingTutorial(animated: false))
            }
            else {
                
                navigate(step: .showTools(animated: true, shouldCreateNewInstance: true, startingToolbarItem: nil))
            }
            
            loadInitialData()
            
            addDeepLinkingObservers()
            
        case .appLaunchedFromBackgroundState:
            
            if let resignedActiveDate = resignedActiveDate {
                
                let currentDate: Date = Date()
                let elapsedTimeInSeconds: TimeInterval = currentDate.timeIntervalSince(resignedActiveDate)
                let elapsedTimeInMinutes: TimeInterval = elapsedTimeInSeconds / 60
                
                if elapsedTimeInMinutes >= 120 {

                    let loadingView: UIView = UIView(frame: UIScreen.main.bounds)
                    let loadingImage: UIImageView = UIImageView(frame: UIScreen.main.bounds)
                    loadingImage.contentMode = .scaleAspectFit
                    loadingView.addSubview(loadingImage)
                    loadingImage.image = UIImage(named: "LaunchImage")
                    loadingView.backgroundColor = .white
                    window.addSubview(loadingView)
                    
                    resetFlowToToolsFlow(startingToolbarItem: nil)
                    loadInitialData()
                    
                    UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
                        loadingView.alpha = 0
                    }, completion: {(finished: Bool) in
                        loadingView.removeFromSuperview()
                    })
                }
            }
            
            resignedActiveDate = nil
            
        case .deepLink(let deepLink):
            
            switch deepLink {
            
            case .tool(let toolDeepLink):
                      
                guard let toolDeepLinkResources = ToolDeepLinkResources(dataDownloader: dataDownloader, languageSettingsService: appDiContainer.languageSettingsService, toolDeepLink: toolDeepLink) else {
                    return
                }
                
                let startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView?
                
                if toolDeepLinkResources.resource.resourceTypeEnum == .lesson {
                    startingToolbarItem = .lessons
                }
                else {
                    startingToolbarItem = nil
                }
                
                resetFlowToToolsFlow(startingToolbarItem: startingToolbarItem)
                
                toolsFlow?.navigateToTool(
                    resource: toolDeepLinkResources.resource,
                    primaryLanguage: toolDeepLinkResources.primaryLanguage,
                    parallelLanguage: toolDeepLinkResources.parallelLanguage,
                    liveShareStream: toolDeepLink.liveShareStream,
                    trainingTipsEnabled: false,
                    page: toolDeepLink.page
                )
            
            case .article(let articleUri):
                
                resetFlowToToolsFlow(startingToolbarItem: nil)
                
                let articleDeepLinkFlow = ArticleDeepLinkFlow(
                    flowDelegate: self,
                    appDiContainer: appDiContainer,
                    sharedNavigationController: navigationController,
                    aemUri: articleUri
                )
                
                self.articleDeepLinkFlow = articleDeepLinkFlow
                            
            case .lessonsList:
                
                resetFlowToToolsFlow(startingToolbarItem: .lessons)
                
            case .favoritedToolsList:
                
                resetFlowToToolsFlow(startingToolbarItem: .favoritedTools)
                
            case .allToolsList:
                
                resetFlowToToolsFlow(startingToolbarItem: .allTools)
            }
        
        case .showTools(let animated, let shouldCreateNewInstance, let startingToolbarItem):
            
            if shouldCreateNewInstance || toolsFlow == nil {

                let toolsFlow: ToolsFlow = ToolsFlow(
                    flowDelegate: self,
                    appDiContainer: appDiContainer,
                    sharedNavigationController: navigationController,
                    startingToolbarItem: startingToolbarItem
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
            
            navigate(step: .showTools(animated: false, shouldCreateNewInstance: false, startingToolbarItem: nil))
            navigationController.dismiss(animated: true, completion: nil)
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
            
        case .buttonWithUrlTappedFromFirebaseInAppMessage(let url):
                        
            let didParseDeepLinkFromUrl: Bool = deepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
            
            if !didParseDeepLinkFromUrl {
                UIApplication.shared.open(url)
            }
                        
        default:
            break
        }
    }
        
    private func dismissTutorial() {
        closeMenu(animated: true)
        navigate(step: .showTools(animated: false, shouldCreateNewInstance: false, startingToolbarItem: nil))
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
}

// MARK: - Notifications

extension AppFlow {
    
    @objc private func handleNotification(notification: Notification) {
        
        if notification.name == UIApplication.willResignActiveNotification {
            
            resignedActiveDate = Date()
        }
        else if notification.name == UIApplication.didBecomeActiveNotification {
            
            let appLaunchedFromTerminatedState: Bool = !navigationStarted
            let appLaunchedFromBackgroundState: Bool = navigationStarted && appIsInBackground
            
            if appLaunchedFromTerminatedState {
                navigationStarted = true
                navigate(step: .appLaunchedFromTerminatedState)
            }
            else if appLaunchedFromBackgroundState {
                appIsInBackground = false
                navigate(step: .appLaunchedFromBackgroundState)
            }
        }
        else if notification.name == UIApplication.didEnterBackgroundNotification {
            appIsInBackground = true
        }
    }
}

// MARK: - FirebaseInAppMessagingDelegate

extension AppFlow: FirebaseInAppMessagingDelegate {
    
    func firebaseInAppMessageActionTappedWithUrl(url: URL) {
        navigate(step: .buttonWithUrlTappedFromFirebaseInAppMessage(url: url))
    }
}
