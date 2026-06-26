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

final class AppFlow: RootFlow {
        
    static let defaultNavBarColor: UIColor = .white
    static let defaultNavBarControlColor: UIColor = ColorPalette.gtBlue.uiColor
    static let defaultNavBarStatusBarStyle: UIStatusBarStyle = .darkContent
    
    private let appDiContainer: AppDiContainer
    private let rootController: AppRootController
    private let deepLinkingService: DeepLinkingService
    private let appMessaging: AppMessagingInterface
    private let appLaunchObserver: AppLaunchObserver = AppLaunchObserver()
    private let launchCountRepository: LaunchCountRepositoryInterface
    private let dashboardFlow: DashboardFlow
    
    private var launchScreenImageView: UIView?
    private var appLaunchedFromDeepLink: ParsedDeepLinkType?
    private var cancellableForShouldPromptForOptInNotification: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
            
    init(appDiContainer: AppDiContainer, appDeepLinkingService: DeepLinkingService, deepLinkUrl: URL?) {
        
        print("x init rootFlow: \(type(of: self))")
        
        let appNavigationController = AppNavigationController(
            navigationBarAppearance: AppNavigationBarAppearance(
                backgroundColor: AppFlow.defaultNavBarColor,
                controlColor: AppFlow.defaultNavBarControlColor,
                titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
                titleColor: AppFlow.defaultNavBarControlColor,
                isTranslucent: false
            ),
            hidesNavigationBar: true
        )
        
        let rootController = AppRootController()
        
        self.appDiContainer = appDiContainer
        self.rootController = rootController
        self.deepLinkingService = appDeepLinkingService
        self.appMessaging = appDiContainer.core.dataLayer.getAppMessaging()
        self.launchCountRepository = appDiContainer.core.dataLayer.getLaunchCountRepository()
        
        dashboardFlow = DashboardFlow(
            appDiContainer: appDiContainer,
            rootController: rootController
        )
        
        if let deepLinkUrl = deepLinkUrl {
            appLaunchedFromDeepLink = appDeepLinkingService.parseDeepLink(
                incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: deepLinkUrl))
            )
        }
                
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = .clear
        rootController.addChildController(child: appNavigationController)
        
        super.init(
            initialView: nil,
            stepEmitter: FlowStepEmitter(),
            rootView: .custom(view: rootController),
            navigationController: appNavigationController
        )
        
        navigationController.delegate = self
                
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
                    weakSelf.navigate(step: AppFlowStep.deepLink(deepLinkType: deepLink))
                }
            }
            .store(in: &cancellables)
        
        appMessaging.setMessagingDelegate(messagingDelegate: self)
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .assign(to: &$appLanguage)
        
        appLaunchObserver
            .onAppLaunchPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (launchState: AppLaunchState) in
                self?.navigate(step: AppFlowStep.appLaunched(state: launchState))
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .appLaunched(let launchState):
                                    
            if launchState.isLaunching {
                
                AppBackgroundState.shared.start(appDiContainer: appDiContainer)
                            
                ApplicationLayout.shared.configure(appLanguageDiContainer: appDiContainer.feature.appLanguage)
            }
            
            switch launchState {
           
            case .willEnterForground:
                attachLaunchScreenImageView()
                
            case .fromTerminatedState:
                
                countAppSessionLaunch()
                
                Task {
                    
                    let onboardingTutorialIsAvailable: Bool = appDiContainer.feature.onboarding.domainLayer.getOnboardingTutorialIsAvailableUseCase().execute()
                    let deferredDeepLink: ParsedDeepLinkType? = await appDiContainer.feature.deferredDeepLink.domainLayer.getDeferredDeepLinkUseCase().execute() // NOTE: I noticed the call to check for deferred deep link will take a second or 2. ~Levi
                                        
                    if !onboardingTutorialIsAvailable {
                        pushFlow(flow: dashboardFlow, animated: false)
                    }
                    
                    let launchCount: Int = launchCountRepository.getLaunchCount()
                    let hasPossibleDeferredDeepLinkInPasteboardForDynalink: Bool = UIPasteboard.general.hasURLs
                    
                    let shouldOpenPasteboardForDeferredDeepLink: Bool = launchCount == 1 && hasPossibleDeferredDeepLinkInPasteboardForDynalink
                    
                    if let deepLink = deferredDeepLink {
                        
                        navigate(step: AppFlowStep.deepLink(deepLinkType: deepLink))
                    }
                    else if let deepLink = appLaunchedFromDeepLink {
                        
                        appLaunchedFromDeepLink = nil
                        navigate(step: AppFlowStep.deepLink(deepLinkType: deepLink))
                    }
                    else if shouldOpenPasteboardForDeferredDeepLink {
                        
                        navigate(step: AppFlowStep.showDeferredDeepLinkModal)
                    }
                    else if onboardingTutorialIsAvailable {
                        
                        navigateToOnboarding()
                    }
                    else {
                        
                        promptForOptInNotificationIfNeeded()
                    }
                    
                    loadInitialData()
                    
                    removeLaunchScreenImageView(animated: true, delay: 1.5)
                }
                
            case .fromBackgroundState(let secondsInBackground):
                
                let elapsedTimeInMinutes: TimeInterval = secondsInBackground / 60
                
                guard elapsedTimeInMinutes >= 120 else {
                    removeLaunchScreenImageView(animated: false, delay: 0)
                    return
                }
                
                loadInitialData()
                countAppSessionLaunch()
                
                dashboardFlow.navigateToDashboard()
                
                promptForOptInNotificationIfNeeded()
                
                removeLaunchScreenImageView(animated: true, delay: 1.5)
                
            case .inBackground:
                break
                
            case .notDetermined:
                break
            }
            
        case .deepLink(let deepLink):
            
            dashboardFlow.navigateToDashboard(
                startingTab: deepLink.dashboardTab,
                didCompleteDismissingPresentedView: { [weak self] in
                    
                    self?.navigateToDeepLink(deepLink: deepLink)
                }
            )
 
        case .showDeferredDeepLinkModal:
            
            let deferredDeepLinkModal = getDeferredDeepLinkModal()
            presentView(view: deferredDeepLinkModal, animated: true)
            
        case .handleDeepLinkFromDeferredDeepLinkModal(let deepLink):
            dismissView(animated: false, completion: { [weak self] in
                self?.navigate(step: AppFlowStep.deepLink(deepLinkType: deepLink))
            })
          
        case .closeTappedFromDeferredDeepLinkModal:
            dashboardFlow.navigateToDashboard()
            dismissView(animated: true)
            
        case .onboardingFlowCompleted( _):
            
            pushFlow(flow: dashboardFlow, animated: false)
            
            dismissFlow()
                        
        case .languageSettingsFlowCompleted( _):
            popFlow()
            
        case .buttonWithUrlTappedFromAppMessage(let url):
                        
            let didParseDeepLinkFromUrl: Bool = deepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
            
            if !didParseDeepLinkFromUrl {
                appDiContainer.getUrlOpener().open(url: url)
            }
            
        case .optInNotificationFlowCompleted( _):
            dismissOptInNotificationFlow()
            
        case .loadingArticleFlowCompleted(let state):
            
            switch state {
            
            case .downloadSuccess(let aemUri):
                pushFlow(
                    flow: ArticleDeepLinkFlow(appDiContainer: appDiContainer, aemUri: aemUri)
                )
                
                dismissFlow()
            
            case .downloadFailed(let alertMessage):
                
                let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()
                let appLanguage: AppLanguageDomainModel = self.appLanguage
                
                dismissFlow(completion: { [weak self] in
                    
                    let view = AlertMessageView(
                        title: alertMessage.title,
                        message: alertMessage.message,
                        acceptTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.ok.key),
                        cancelTitle: nil,
                        acceptTapped: nil,
                        cancelTapped: nil
                    )
                    
                    self?.presentView(view: view.controller, animated: true)
                })
            }
            
        case .articleDeepLinkFlowCompleted( _):
            popFlow()
                        
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
        
        let resourcesRepository: ResourcesRepository = appDiContainer.core.dataLayer.getResourcesRepository()
        let toolLanguageDownloader: ToolLanguageDownloader = appDiContainer.feature.appLanguage.dataLayer.getToolLanguageDownloader()
        let followUpsService: FollowUpsService = appDiContainer.core.dataLayer.getFollowUpsService()
        let resourceViewsService: ResourceViewsService = appDiContainer.core.dataLayer.getResourceViewsService()
        let remoteConfigRepository: RemoteConfigRepository = appDiContainer.core.dataLayer.getRemoteConfigRepository()
        
        Task {
            
            _ = try await resourcesRepository
                .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments(
                    requestPriority: .medium,
                    forceFetchFromRemote: false
                )
            
            _ = try await toolLanguageDownloader
                .syncDownloadedLanguages()
        }
        
        Task {
            
            try await followUpsService.postFailedFollowUpsIfNeeded(
                requestPriority: .low
            )
        }
        
        Task {
            
            try await resourceViewsService.postFailedResourceViewsIfNeeded(
                requestPriority: .low
            )
        }
        
        Task {
            
            try await remoteConfigRepository
                .syncData()
        }
        
        Task {
            
            let userAuthentication: UserAuthentication = appDiContainer.core.dataLayer.getUserAuthentication()
            
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
    
    private func getNewLaunchScreenImageView() -> UIImageView {
        
        let imageView: UIImageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageCatalog.launchImage.uiImage
        
        return imageView
    }
    
    private func attachLaunchScreenImageView() {
        
        guard launchScreenImageView == nil else {
            return
        }
        
        let launchScreenImageView: UIImageView = getNewLaunchScreenImageView()
        
        GodToolsSceneDelegate.getWindow()?.addSubview(launchScreenImageView)
        
        self.launchScreenImageView = launchScreenImageView
    }
    
    private func removeLaunchScreenImageView(animated: Bool, delay: TimeInterval) {
        
        guard let launchScreenImageView = self.launchScreenImageView else {
            return
        }
        
        if animated {
            
            UIView.animate(withDuration: 0.4, delay: delay, options: .curveEaseOut, animations: {
                launchScreenImageView.alpha = 0
            }, completion: { [weak self] (finished: Bool) in
                launchScreenImageView.removeFromSuperview()
                self?.launchScreenImageView = nil
            })
        }
        else {
            launchScreenImageView.removeFromSuperview()
            self.launchScreenImageView = nil
        }
    }
}

// MARK: - Deep Link

extension AppFlow {
    
    private func navigateToDeepLink(deepLink: ParsedDeepLinkType) {
                
        switch deepLink {
        
        case .tool(let toolDeepLink):

            dashboardFlow.navigateToToolFromDeepLink(
                appLanguage: appLanguage,
                toolDeepLink: toolDeepLink
            )
            
        case .articleAemUri(let aemUri):
            
            let aemCacheObject: ArticleAemCacheObject? = appDiContainer.core.dataLayer.getArticleAemRepository()
                .getAemCacheObject(aemUri: aemUri)
            
            if let aemCacheObject = aemCacheObject {
                
                pushFlow(
                    flow: ArticleDeepLinkFlow(
                        appDiContainer: appDiContainer,
                        aemUri: aemCacheObject.aemUri
                    )
                )
            }
            else {
                
                presentFlow(
                    flow: LoadingArticleFlow(
                        appDiContainer: appDiContainer,
                        appLanguage: appLanguage,
                        aemUri: aemUri
                    )
                )
            }
            
        case .languageSettings:
            pushFlow(
                flow: LanguageSettingsFlow(
                    appDiContainer: appDiContainer,
                    deepLink: nil
                )
            )
            
        case .appLanguagesList:
            pushFlow(
                flow: LanguageSettingsFlow(
                    appDiContainer: appDiContainer,
                    deepLink: .appLanguagesList
                ),
                animated: false
            )
            
        case .lessonsList:
            break
            
        case .favoritedToolsList:
            break
            
        case .allToolsList:
            break
            
        case .dashboard:
            break
            
        case .menu:
            
            dashboardFlow.navigateToMenu(
                animated: true,
                initialNavigationStep: nil
            )
            
        case .onboarding(let appLanguage):
            
            let userAppLanguageRepository: UserAppLanguageRepository = appDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository()
            
            Task {
                try await userAppLanguageRepository
                    .storeLanguage(appLanguageId: appLanguage)
            }
                        
            navigateToOnboarding()
        }
    }
    
    private func getDeferredDeepLinkModal() -> UIViewController {
        
        let viewModel = DeferredDeepLinkModalViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDeferredDeepLinkModalStringsUseCase: appDiContainer.feature.deferredDeepLink.domainLayer.getDeferredDeepLinkModalStringsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
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

// MARK: - Onboarding

extension AppFlow {
    
    private func navigateToOnboarding(animated: Bool = true) {
        
        presentFlow(
            flow: OnboardingFlow(appDiContainer: appDiContainer),
            animated: animated
        )
    }
}

// MARK: - Opt-In Notification

extension AppFlow {
    
    private func promptForOptInNotificationIfNeeded() {
        
        Task {
            
            guard !isPresentingFlow && presentedFlow == nil else {
                return
            }
            
            let shouldPrompt: Bool = try await getShouldPromptForOptInNotification()
            
            guard shouldPrompt else {
                return
            }
            
            let notificationPromptType: OptInNotificationViewModel.NotificationPromptType = try await getNotificationPromptType()
            
            presentFlow(
                flow: OptInNotificationFlow(
                    appDiContainer: appDiContainer,
                    notificationPromptType: notificationPromptType
                )
            )
        }
    }
    
    private func dismissOptInNotificationFlow() {
        
        dismissFlow()
    }
    
    private func getShouldPromptForOptInNotification() async throws -> Bool {
        
        return try await appDiContainer.feature.optInNotification.domainLayer
            .getShouldPromptForOptInNotificationUseCase()
            .execute()
    }
    
    private func getNotificationPromptType() async throws -> OptInNotificationViewModel.NotificationPromptType {
        
        let status: PermissionStatusDomainModel = try await appDiContainer.feature
            .optInNotification
            .domainLayer
            .getCheckNotificationStatusUseCase()
            .execute()
        
        let notificationPromptType: OptInNotificationViewModel.NotificationPromptType
        
        switch status {
        case .undetermined:
            notificationPromptType = .allow
        default:
            notificationPromptType = .settings
        }
        
        return notificationPromptType
    }
}

// MARK: - AppMessagingDelegate

extension AppFlow: AppMessagingDelegate {
    
    func actionTappedWithUrl(url: URL, didOpenUrl: Bool) {
        
        if !didOpenUrl {
            navigate(step: AppFlowStep.buttonWithUrlTappedFromAppMessage(url: url))
        }
    }
}
