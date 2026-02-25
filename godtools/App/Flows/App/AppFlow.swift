//
//  AppFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI
import SwiftUI
import Combine

class AppFlow: NSObject, Flow {
        
    static let defaultNavBarColor: UIColor = .white
    static let defaultNavBarControlColor: UIColor = ColorPalette.gtBlue.uiColor
    static let defaultNavBarStatusBarStyle: UIStatusBarStyle = .darkContent
    
    private let deepLinkingService: DeepLinkingService
    private let appMessaging: AppMessagingInterface
    private let appLaunchObserver: AppLaunchObserver = AppLaunchObserver()
    private let launchCountRepository: LaunchCountRepositoryInterface
    private let dashboardFlow: DashboardFlow
    private let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    
    private var onboardingFlow: OnboardingFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var articleDeepLinkFlow: ArticleDeepLinkFlow?
    private var appLaunchedFromDeepLink: ParsedDeepLinkType?
    private var optInNotificationFlow: OptInNotificationFlow?
    private var cancellableForAppLaunchedFromTerminatedStateOptions: AnyCancellable?
    private var cancellableForShouldPromptForOptInNotification: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
        
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    let rootView: AppRootView
            
    init(appDiContainer: AppDiContainer, appDeepLinkingService: DeepLinkingService) {
        
        let navigationBarAppearance = AppNavigationBarAppearance(
            backgroundColor: AppFlow.defaultNavBarColor,
            controlColor: AppFlow.defaultNavBarControlColor,
            titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
            titleColor: AppFlow.defaultNavBarControlColor,
            isTranslucent: false
        )
        
        self.appDiContainer = appDiContainer
        self.navigationController = AppNavigationController(navigationBarAppearance: navigationBarAppearance, hidesNavigationBar: true)
        self.rootView = AppRootView(appRootController: rootController)
        self.deepLinkingService = appDeepLinkingService
        self.appMessaging = appDiContainer.dataLayer.getAppMessaging()
        self.launchCountRepository = appDiContainer.dataLayer.getLaunchCountRepository()
        self.dashboardFlow = DashboardFlow(appDiContainer: appDiContainer, sharedNavigationController: navigationController, rootController: rootController)
        
        super.init()
        
        navigationController.delegate = self
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = .clear
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        
        rootController.addChildController(child: navigationController)
        
        deepLinkingService
            .parsedDeepLinkPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (deepLink: ParsedDeepLinkType?) in
                
                guard let weakSelf = self, let deepLink = deepLink else {
                    return
                }
                
                if !weakSelf.appLaunchObserver.appLaunched {
                    weakSelf.appLaunchedFromDeepLink = deepLink
                }
                else {
                    weakSelf.navigate(step: .deepLink(deepLinkType: deepLink))
                }
            }
            .store(in: &cancellables)
        
        appMessaging.setMessagingDelegate(messagingDelegate: self)
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        appLaunchObserver
            .onAppLaunchPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (launchState: AppLaunchState) in
                self?.navigate(step: .appLaunched(state: launchState))
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {

        switch step {
            
        case .appLaunched(let launchState):
            
            if launchState.isLaunching {
                
                AppBackgroundState.shared.start(appDiContainer: appDiContainer)
                            
                ApplicationLayout.shared.configure(appLanguageFeatureDiContainer: appDiContainer.feature.appLanguage)
            }
            
            switch launchState {
           
            case .fromTerminatedState:
                
                loadInitialData()
                countAppSessionLaunch()
                
                let getOnboardingTutorialIsAvailableUseCase: GetOnboardingTutorialIsAvailableUseCase = appDiContainer.feature.onboarding.domainLayer.getOnboardingTutorialIsAvailableUseCase()
                let shouldPromptForOptInNotificationUseCase: ShouldPromptForOptInNotificationUseCase = appDiContainer.feature.optInNotification.domainLayer.getShouldPromptForOptInNotificationUseCase()
                
                cancellableForAppLaunchedFromTerminatedStateOptions = Publishers.CombineLatest(
                    getOnboardingTutorialIsAvailableUseCase.getAvailablePublisher(),
                    shouldPromptForOptInNotificationUseCase.shouldPromptPublisher()
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] (onboardingTutorialIsAvailable: Bool, shouldPromptForOptInNotification: Bool) in
                   
                    guard let appFlow = self else {
                        return
                    }
                    
                    appFlow.cancellableForAppLaunchedFromTerminatedStateOptions = nil
                    
                    let launchCount: Int = appFlow.launchCountRepository.getLaunchCount()
                    
                    if launchCount == 1, UIPasteboard.general.hasURLs {
                        
                        appFlow.navigate(step: .showDeferredDeepLinkModal)
                        
                    } else if let deepLink = appFlow.appLaunchedFromDeepLink {
                        
                        appFlow.appLaunchedFromDeepLink = nil
                        appFlow.navigate(step: .deepLink(deepLinkType: deepLink))
                    }
                    else if onboardingTutorialIsAvailable {
                        
                        appFlow.navigate(step: .showOnboardingTutorial(animated: true))
                    }
                    else {
                        
                        appFlow.dashboardFlow.navigateToDashboard()

                        if shouldPromptForOptInNotification {
                            appFlow.presentOptInNotificationFlow()
                        }
                    }
                })
                
            case .fromBackgroundState(let secondsInBackground):
                
                let elapsedTimeInMinutes: TimeInterval = secondsInBackground / 60
                
                guard elapsedTimeInMinutes >= 120 else {
                    return
                }
                
                loadInitialData()
                countAppSessionLaunch()
                
                let loadingView: UIView = attachLaunchedFromBackgroundLoadingView()
                
                dashboardFlow.navigateToDashboard()
                
                promptForOptInNotificationIfNeeded()
                
                removeLaunchedFromBackgroundLoadingView(view: loadingView)
                
            case .inBackground:
                break
                
            case .notDetermined:
                break
            }
            
        case .deepLink(let deepLink):
            navigateToDeepLink(deepLink: deepLink)
            
        case .showDeferredDeepLinkModal:
            
            let deferredDeepLinkModal = getDeferredDeepLinkModal()
            navigationController.present(deferredDeepLinkModal, animated: true)
            
        case .handleDeepLinkFromDeferredDeepLinkModal(let deepLink):
            
            navigationController.dismissPresented(animated: false) { [weak self] in
                self?.navigate(step: .deepLink(deepLinkType: deepLink))
            }
                        
        case .closeTappedFromDeferredDeepLinkModal:
            dashboardFlow.navigateToDashboard()
            navigationController.dismissPresented(animated: true, completion: nil)
            
        case .showOnboardingTutorial(let animated):
            navigateToOnboarding(animated: animated)
            
        case .onboardingFlowCompleted(let onboardingFlowCompletedState):
            
            switch onboardingFlowCompletedState {
            
            case .completed:
                dashboardFlow.navigateToDashboard()
                
            default:
                dashboardFlow.navigateToDashboard()
            }
            
            dismissOnboarding(animated: true)
                        
        case .languageSettingsFlowCompleted( _):
            closeLanguageSettings()
            
        case .buttonWithUrlTappedFromAppMessage(let url):
                        
            let didParseDeepLinkFromUrl: Bool = deepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
            
            if !didParseDeepLinkFromUrl {
                appDiContainer.getUrlOpener().open(url: url)
            }
            
        case .optInNotificationFlowCompleted( _):
            dismissOptInNotificationFlow()
                        
        default:
            break
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension AppFlow: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isDashboard: Bool = viewController is AppHostingController<DashboardView>
        let isLesson: Bool = viewController is LessonView
        let hidesNavigationBar: Bool = isDashboard || isLesson
        
        if isDashboard {
            dashboardFlow.configureNavBarForDashboard()
        }
        
        navigationController.setNavigationBarHidden(hidesNavigationBar, animated: false)
    }
}

// MARK: - Launch

extension AppFlow {
    
    private func loadInitialData() {
        
        let resourcesRepository: ResourcesRepository = appDiContainer.dataLayer.getResourcesRepository()
        let toolLanguageDownloader: ToolLanguageDownloader = appDiContainer.feature.appLanguage.dataLayer.getToolLanguageDownloader()
        let followUpsService: FollowUpsService = appDiContainer.dataLayer.getFollowUpsService()
        let resourceViewsService: ResourceViewsService = appDiContainer.dataLayer.getResourceViewsService()
        let remoteConfigRepository: RemoteConfigRepository = appDiContainer.dataLayer.getRemoteConfigRepository()
        
        resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: .medium, forceFetchFromRemote: false)
            .flatMap({ (result: ResourcesCacheSyncResult) -> AnyPublisher<Void, Error> in
                
                return toolLanguageDownloader
                    .syncDownloadedLanguagesPublisher()
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
        
        followUpsService
            .postFailedFollowUpsIfNeededPublisher(requestPriority: .low)
            .sink { _ in
                
            }
            .store(in: &cancellables)
      
        resourceViewsService
            .postFailedResourceViewsIfNeededPublisher(requestPriority: .low)
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        remoteConfigRepository
            .syncDataPublisher()
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        Task {
            
            let userAuthentication: UserAuthentication = appDiContainer.dataLayer.getUserAuthentication()
            
            _ = try await userAuthentication.renewToken()
            _ = try await userAuthentication.getAuthUser()
        }
    }
    
    private func countAppSessionLaunch() {
        
        let incrementUserCounterUseCase = appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase()
        
        incrementUserCounterUseCase
            .execute(
                interaction: .sessionLaunch
            )
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
    
    private func attachLaunchedFromBackgroundLoadingView() -> UIView {
        
        let loadingView: UIView = UIView(frame: UIScreen.main.bounds)
        let loadingImage: UIImageView = UIImageView(frame: UIScreen.main.bounds)
        loadingImage.contentMode = .scaleAspectFit
        loadingView.addSubview(loadingImage)
        loadingImage.image = ImageCatalog.launchImage.uiImage
        loadingView.backgroundColor = .white
        GodToolsSceneDelegate.getWindow()?.addSubview(loadingView)
        
        return loadingView
    }
    
    private func removeLaunchedFromBackgroundLoadingView(view: UIView) {
        
        UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
            view.alpha = 0
        }, completion: {(finished: Bool) in
            view.removeFromSuperview()
        })
    }
}

// MARK: - Onboarding

extension AppFlow {
    
    private func navigateToOnboarding(animated: Bool) {
        
        guard onboardingFlow == nil else {
            return
        }
        
        let onboardingFlow = OnboardingFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer
        )
        
        navigationController.present(onboardingFlow.navigationController, animated: animated, completion: nil)
        
        self.onboardingFlow = onboardingFlow
    }
    
    private func dismissOnboarding(animated: Bool, completion: (() -> Void)? = nil) {
        
        guard onboardingFlow != nil else {
            return
        }
        
        navigationController.dismissPresented(animated: animated, completion: completion)
        
        onboardingFlow = nil
    }
}

// MARK: - Deep Link

extension AppFlow {
    
    private func navigateToDeepLink(deepLink: ParsedDeepLinkType) {
        
        switch deepLink {
        
        case .tool(let toolDeepLink):
               
            dashboardFlow.navigateToDashboard(startingTab: .favorites, animatePopToToolsMenu: false, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: nil)
                        
            dashboardFlow.navigateToToolFromToolDeepLink(appLanguage: appLanguage, toolDeepLink: toolDeepLink, didCompleteToolNavigation: nil)
            
        case .articleAemUri(let aemUri):
            
            dashboardFlow.navigateToDashboard(startingTab: .favorites, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                
                let articleDeepLinkFlow = ArticleDeepLinkFlow(
                    flowDelegate: weakSelf,
                    appDiContainer: weakSelf.appDiContainer,
                    sharedNavigationController: weakSelf.navigationController,
                    aemUri: aemUri
                )
                
                weakSelf.articleDeepLinkFlow = articleDeepLinkFlow
            })
            
        case .languageSettings:
            dashboardFlow.navigateToDashboard(startingTab: .favorites)
            navigateToLanguageSettings(deepLink: nil)
            
        case .appLanguagesList:
            dashboardFlow.navigateToDashboard(startingTab: .favorites)
            navigateToLanguageSettings(deepLink: .appLanguagesList)
            
        case .lessonsList:
            dashboardFlow.navigateToDashboard(startingTab: .lessons)
            
        case .favoritedToolsList:
            dashboardFlow.navigateToDashboard(startingTab: .favorites)
            
        case .allToolsList:
            dashboardFlow.navigateToDashboard(startingTab: .tools, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: nil)
            
        case .dashboard:
            dashboardFlow.navigateToDashboard(startingTab: .favorites)
            
        case .onboarding(let appLanguage):
            
            let userAppLanguageRepository: UserAppLanguageRepository = appDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository()
            
            userAppLanguageRepository
                .storeLanguagePublisher(appLanguageId: appLanguage)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { _ in
                    
                })
                .store(in: &cancellables)
                        
            navigateToOnboarding(animated: true)
        }
    }
    
    private func getDeferredDeepLinkModal() -> UIViewController {
        let viewModel = DeferredDeepLinkModalViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDeferredDeepLinkModalInterfaceStringsUseCase: appDiContainer.feature.deferredDeepLink.domainLayer.getDeferredDeepLinkModalInterfaceStringsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            deepLinkingService: deepLinkingService
        )
        
        let view = DeferredDeepLinkModalView(viewModel: viewModel)
        
        let hostingController = AppHostingController<DeferredDeepLinkModalView>(
            rootView: view,
            navigationBar: nil
        )
        
        hostingController.modalPresentationStyle = .fullScreen
        
        return hostingController
    }
}

// MARK: - Language Settings

extension AppFlow {
    
    private func navigateToLanguageSettings(deepLink: ParsedDeepLinkType?) {
        
        let languageSettingsFlow = LanguageSettingsFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            deepLink: deepLink
        )
        
        self.languageSettingsFlow = languageSettingsFlow
    }
    
    private func closeLanguageSettings() {
        
        guard languageSettingsFlow != nil else {
            return
        }
        
        navigationController.popViewController(animated: true)
        
        self.languageSettingsFlow = nil
    }
}

// MARK: - Opt-In Notification

extension AppFlow {

    private func promptForOptInNotificationIfNeeded() {
        
        cancellableForShouldPromptForOptInNotification = appDiContainer.feature.optInNotification.domainLayer
            .getShouldPromptForOptInNotificationUseCase()
            .shouldPromptPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (shouldPrompt: Bool) in
                
                self?.cancellableForShouldPromptForOptInNotification = nil
                
                if shouldPrompt {
                    self?.presentOptInNotificationFlow()
                }
            }
    }
    
    private func presentOptInNotificationFlow() {
        
        guard optInNotificationFlow == nil else {
            return
        }
        
        let optInNotificationFlow = OptInNotificationFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            presentOnNavigationController: navigationController
        )
        
        self.optInNotificationFlow = optInNotificationFlow
    }
    
    private func dismissOptInNotificationFlow() {
        
        guard optInNotificationFlow != nil else {
            return
        }
        
        navigationController.dismissPresented(animated: true, completion: nil)
        optInNotificationFlow = nil
    }
}

// MARK: - AppMessagingDelegate

extension AppFlow: AppMessagingDelegate {
    
    func actionTappedWithUrl(url: URL) {
        navigate(step: .buttonWithUrlTappedFromAppMessage(url: url))
    }
}
