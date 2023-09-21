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

class AppFlow: NSObject, ToolNavigationFlow, Flow {
    
    private static let defaultStartingDashboardTab: DashboardTabTypeDomainModel = .favorites
    
    private let dataDownloader: InitialDataDownloader
    private let followUpsService: FollowUpsService
    private let resourceViewsService: ResourceViewsService
    private let deepLinkingService: DeepLinkingService
    private let onboardingTutorialIsAvailable: Bool
    private let inAppMessaging: FirebaseInAppMessaging
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var tutorialFlow: TutorialFlow?
    private var learnToShareToolFlow: LearnToShareToolFlow?
    private var articleDeepLinkFlow: ArticleDeepLinkFlow?
    private var appLaunchedFromDeepLink: ParsedDeepLinkType?
    private var dashboardLanguageSettingsButton: UIBarButtonItem?
    private var resignedActiveDate: Date?
    private var navigationStarted: Bool = false
    private var uiApplicationLifeCycleObserversAdded: Bool = false
    private var appIsInBackground: Bool = false
    private var isObservingDeepLinking: Bool = false
    private var cancellables: Set<AnyCancellable> = Set()
    
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
            
    init(appDiContainer: AppDiContainer, appDeepLinkingService: DeepLinkingService) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
        self.dataDownloader = appDiContainer.dataLayer.getInitialDataDownloader()
        self.followUpsService = appDiContainer.dataLayer.getFollowUpsService()
        self.resourceViewsService = appDiContainer.dataLayer.getResourceViewsService()
        self.deepLinkingService = appDeepLinkingService
        self.onboardingTutorialIsAvailable = appDiContainer.domainLayer.getOnboardingTutorialAvailabilityUseCase().getOnboardingTutorialIsAvailable().isAvailable
        self.inAppMessaging = appDiContainer.dataLayer.getFirebaseInAppMessaing()
        
        super.init()
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = .clear
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        
        rootController.addChildController(child: navigationController)
        
        addUIApplicationLifeCycleObservers()
        addDeepLinkingObservers()
        
        inAppMessaging.setDelegate(delegate: self)
                
        // NOTE: This fixes a bug with the Dashboard TabView that occurs when launching the app from a terminated state.
        // The bug occurs when the Dashboard TabView starts on any index other than 0 and then tab index 0 is tapped.  Tab index 0 will correctly highlight, but tab navigation doesn't occur.
        // This happens in the device in iOS 16.3.1.
        // I think this bug has something to do with attaching SwiftUI views to UIKit during UIApplicationDelegate life cycle.
        if !onboardingTutorialIsAvailable {
            navigateToDashboard()
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeUIApplicationLifeCycleObservers()
        removeDeepLinkingObservers()
    }
    
    func getInitialView() -> UIViewController {
        return rootController
    }
    
    func navigate(step: FlowStep) {

        switch step {
        
        case .appLaunchedFromTerminatedState:
                       
            if let deepLink = appLaunchedFromDeepLink {
                
                appLaunchedFromDeepLink = nil
                navigate(step: .deepLink(deepLinkType: deepLink))
            }
            else if onboardingTutorialIsAvailable {
                
                navigate(step: .showOnboardingTutorial(animated: true))
            }
            else {
                
                navigateToDashboard()
            }
            
            loadInitialData()
            countAppSessionLaunch()
                        
        case .appLaunchedFromBackgroundState:
            
            guard let resignedActiveDate = self.resignedActiveDate else {
                return
            }
            
            let currentDate: Date = Date()
            let elapsedTimeInSeconds: TimeInterval = currentDate.timeIntervalSince(resignedActiveDate)
            let elapsedTimeInMinutes: TimeInterval = elapsedTimeInSeconds / 60
            
            if elapsedTimeInMinutes >= 120 {

                let loadingView: UIView = UIView(frame: UIScreen.main.bounds)
                let loadingImage: UIImageView = UIImageView(frame: UIScreen.main.bounds)
                loadingImage.contentMode = .scaleAspectFit
                loadingView.addSubview(loadingImage)
                loadingImage.image = ImageCatalog.launchImage.uiImage
                loadingView.backgroundColor = .white
                AppDelegate.getWindow()?.addSubview(loadingView)
                
                navigateToDashboard()
                                
                loadInitialData()
                                
                UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
                    loadingView.alpha = 0
                }, completion: {(finished: Bool) in
                    loadingView.removeFromSuperview()
                })
                
                countAppSessionLaunch()
            }
            
            self.resignedActiveDate = nil
            
        case .deepLink(let deepLink):
            navigateToDeepLink(deepLink: deepLink)
                        
        case .toolTappedFromTools(let resource):
            navigationController.pushViewController(getToolDetails(resource: resource), animated: true)
                                    
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .lessonTappedFromLessonsList(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .lessonTappedFromFavorites(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .viewAllFavoriteToolsTappedFromFavorites:
            navigationController.pushViewController(getAllFavoriteTools(), animated: true)
            
        case .toolDetailsTappedFromFavorites(let tool):
            navigationController.pushViewController(getToolDetails(resource: tool.resource), animated: true)
        
        case .openToolTappedFromFavorites(let tool):
            navigateToTool(resourceId: tool.resource.id, trainingTipsEnabled: false)
            
        case .toolTappedFromFavorites(let tool):
            navigateToTool(resourceId: tool.resource.id, trainingTipsEnabled: false)
            
        case .unfavoriteToolTappedFromFavorites(let tool):
            navigationController.present(getConfirmRemoveToolFromFavoritesAlertView(tool: tool, didConfirmToolRemovalSubject: nil), animated: true)
            
        case .goToToolsTappedFromFavorites:
            navigateToDashboard(startingTab: .tools)
            
        case .backTappedFromAllYourFavoriteTools:
            navigationController.popViewController(animated: true)
            
        case .toolDetailsTappedFromAllYourFavoriteTools(let tool):
            navigationController.pushViewController(getToolDetails(resource: tool.resource), animated: true)
        
        case .openToolTappedFromAllYourFavoriteTools(let tool):
            navigateToTool(resourceId: tool.resource.id, trainingTipsEnabled: false)
            
        case .toolTappedFromAllYourFavoritedTools(let tool):
            navigateToTool(resourceId: tool.resource.id, trainingTipsEnabled: false)
        
        case .unfavoriteToolTappedFromAllYourFavoritedTools(let tool, let didConfirmToolRemovalSubject):
            navigationController.present(getConfirmRemoveToolFromFavoritesAlertView(tool: tool, didConfirmToolRemovalSubject: didConfirmToolRemovalSubject), animated: true)
            
        case .backTappedFromToolDetails:
            navigationController.popViewController(animated: true)
            
        case .articleFlowCompleted( _):
            
            guard articleFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
                        
            articleFlow = nil
            
        case .lessonFlowCompleted(let state):
            
            guard lessonFlow != nil else {
                return
            }
            
            navigateToDashboard(startingTab: .lessons, animatePopToToolsMenu: true, animateDismissingPresentedView: true, didCompleteDismissingPresentedView: nil)
                        
            lessonFlow = nil
            
            switch state {
            
            case .userClosedLesson(let lesson, let highestPageNumberViewed):
                
                let lessonEvaluationRepository: LessonEvaluationRepository = appDiContainer.dataLayer.getLessonsEvaluationRepository()
                let lessonEvaluated: Bool
                let numberOfEvaluationAttempts: Int
                
                if let cachedLessonEvaluation = lessonEvaluationRepository.getLessonEvaluation(lessonId: lesson.id) {
                    lessonEvaluated = cachedLessonEvaluation.lessonEvaluated
                    numberOfEvaluationAttempts = cachedLessonEvaluation.numberOfEvaluationAttempts
                }
                else {
                    lessonEvaluated = false
                    numberOfEvaluationAttempts = 0
                }
                
                let lessonMarkedAsEvaluated: Bool = lessonEvaluated || numberOfEvaluationAttempts > 0
                
                if highestPageNumberViewed > 2 && !lessonMarkedAsEvaluated {
                    presentLessonEvaluation(lesson: lesson, pageIndexReached: highestPageNumberViewed)
                }
            }
            
        case .tractFlowCompleted(let state):
            
            guard tractFlow != nil else {
                return
            }
            
            if state == .userClosedTractToLessonsList {
                
                navigateToDashboard(startingTab: .lessons, animatePopToToolsMenu: true)
            }
            else if let dashboardInNavigationStack = getDashboardInNavigationStack() {
                
                configureNavBarForDashboard()
                navigationController.popToViewController(dashboardInNavigationStack, animated: true)
            }
            else {
                
                configureNavBarForDashboard()
                _ = navigationController.popViewController(animated: true)
            }
            
            tractFlow = nil
            
        case .chooseYourOwnAdventureFlowCompleted(let state):
           
            switch state {
            
            case .userClosedTool:
                
                if let dashboardInNavigationStack = getDashboardInNavigationStack() {
                    
                    configureNavBarForDashboard()
                    navigationController.popToViewController(dashboardInNavigationStack, animated: true)
                }
                else {
                    
                    configureNavBarForDashboard()
                    _ = navigationController.popViewController(animated: true)
                }
                
                chooseYourOwnAdventureFlow = nil
            }
            
        case .urlLinkTappedFromToolDetail(let url, let trackExitLinkAnalytics):
            navigateToURL(url: url, trackExitLinkAnalytics: trackExitLinkAnalytics)
            
        case .showOnboardingTutorial(let animated):
            navigateToOnboarding(animated: animated)
            
        case .onboardingFlowCompleted(let onboardingFlowCompletedState):
            
            switch onboardingFlowCompletedState {
            
            case .readArticles:
                   
                navigateToDashboard()
                
                let deviceLanguageCode = appDiContainer.domainLayer.getDeviceLanguageUseCase().getDeviceLanguage().localeLanguageCode
                
                let toolDeepLink = ToolDeepLink(
                    resourceAbbreviation: "es",
                    primaryLanguageCodes: [deviceLanguageCode],
                    parallelLanguageCodes: [],
                    liveShareStream: nil,
                    page: nil,
                    pageId: nil
                )
                
                navigateToToolFromToolDeepLink(toolDeepLink: toolDeepLink, didCompleteToolNavigation: nil)
                
            case .tryLessons:
                navigateToDashboard(startingTab: .lessons)
                
            case .chooseTool:
                navigateToDashboard(startingTab: .tools)
                
            default:
                navigateToDashboard()
            }
            
            dismissOnboarding(animated: true)
                    
        case .openTutorialTappedFromTools:
            navigateToTutorial()
    
        case .closeTappedFromTutorial:
            dismissTutorial()
            
        case .startUsingGodToolsTappedFromTutorial:
            dismissTutorial()
            
        case .menuTappedFromTools:
            navigateToMenu(animated: true)
            
        case .doneTappedFromMenu:
            closeMenu(animated: true)
            
        case .languageSettingsTappedFromTools:
            navigateToLanguageSettings()
            
        case .languageSettingsFlowCompleted( _):
            closeLanguageSettings()
            
        case .userViewedFavoritedToolsListFromTools:
            presentSetupParallelLanguage()
            
        case .userViewedAllToolsListFromTools:
            presentSetupParallelLanguage()
            
        case .buttonWithUrlTappedFromFirebaseInAppMessage(let url):
                        
            let didParseDeepLinkFromUrl: Bool = deepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
            
            if !didParseDeepLinkFromUrl {
                UIApplication.shared.open(url)
            }
            
        case .learnToShareToolTappedFromToolDetails(let resource):
            navigateToLearnToShareTool(resource: resource)
            
        case .continueTappedFromLearnToShareTool(let resource):
            dismissLearnToShareToolFlow {
                self.navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
            }
            
        case .closeTappedFromLearnToShareTool(let resource):
            dismissLearnToShareToolFlow {
                self.navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
            }
            
        case .closeTappedFromLessonEvaluation:
            dismissLessonEvaluation()
            
        case .sendFeedbackTappedFromLessonEvaluation:
            dismissLessonEvaluation()
        
        case .backgroundTappedFromLessonEvaluation:
            dismissLessonEvaluation()
                    
        case .languageSelectorTappedFromSetupParallelLanguage:
            presentParallelLanguage()
        
        case .yesTappedFromSetupParallelLanguage:
            presentParallelLanguage()
        
        case .noThanksTappedFromSetupParallelLanguage:
            dismissSetupParallelLanguage()
        
        case .getStartedTappedFromSetupParallelLanguage:
            dismissSetupParallelLanguage()
        
        case .languageSelectedFromParallelLanguageList:
            dismissParallelLanguage()
        
        case .backgroundTappedFromSetupParallelLanguage:
            dismissSetupParallelLanguage()
        
        case .backgroundTappedFromParallelLanguageList:
            dismissParallelLanguage()
                        
        default:
            break
        }
    }
}

// MARK: - Launch

extension AppFlow {
    
    private func loadInitialData() {
        
        dataDownloader.downloadInitialData()
        
        _ = followUpsService.postFailedFollowUpsIfNeeded()
        
        _ = resourceViewsService.postFailedResourceViewsIfNeeded()
        
        let userAuthentication: AuthenticateUserInterface = appDiContainer.dataLayer.getUserAuthentication()
        
        userAuthentication.renewAuthenticationPublisher()
            .sink { finished in

            } receiveValue: { authUser in

            }
            .store(in: &cancellables)
    }
    
    private func countAppSessionLaunch() {
        
        let incrementUserCounterUseCase = appDiContainer.domainLayer.getIncrementUserCounterUseCase()
        
        incrementUserCounterUseCase.incrementUserCounter(for: .sessionLaunch)
            .sink { _ in
                
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
}

// MARK: - Tools Menu

extension AppFlow {
    
    private func getDashboardInNavigationStack() -> UIHostingController<DashboardView>? {
        
        for viewController in navigationController.viewControllers {
            if let dashboardView = viewController as? UIHostingController<DashboardView> {
                return dashboardView
            }
        }
        
        return nil
    }
    
    private func getNewDashboardView(startingTab: DashboardTabTypeDomainModel?) -> UIViewController {
        
        let dashboardShowsLanguageSettingsButton: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
        
        let viewModel = DashboardViewModel(
            startingTab: startingTab ?? AppFlow.defaultStartingDashboardTab,
            flowDelegate: self,
            dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies(
                appDiContainer: appDiContainer,
                flowDelegate: self
            ),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            showsLanguagesSettingsButton: dashboardShowsLanguageSettingsButton
        )
        
        let languageSettingsButton = UIBarButtonItem()
        languageSettingsButton.image = ImageCatalog.navLanguage.uiImage
        languageSettingsButton.tintColor = .white
        languageSettingsButton.target = viewModel
        languageSettingsButton.action = #selector(viewModel.languageSettingsTapped)
        
        dashboardLanguageSettingsButton = languageSettingsButton
        
        let view = DashboardView(viewModel: viewModel)
        
        let hostingController: UIHostingController<DashboardView> = UIHostingController(rootView: view)
        
        _ = hostingController.addBarButtonItem(
            to: .left,
            image: ImageCatalog.navMenu.uiImage,
            color: .white,
            target: viewModel,
            action: #selector(viewModel.menuTapped)
        )
        
        dashboardShowsLanguageSettingsButton
            .receive(on: DispatchQueue.main)
            .sink { (showsLanguageSettingsButton: Bool) in
                
                if showsLanguageSettingsButton {
                    hostingController.addBarButtonItem(item: languageSettingsButton, barPosition: .right)
                }
                else {
                    hostingController.removeBarButtonItem(item: languageSettingsButton)
                }
            }
            .store(in: &cancellables)
    
        return hostingController
    }
    
    private func configureNavBarForDashboard() {
        
        AppDelegate.setWindowBackgroundColorForStatusBarColor(color: ColorPalette.gtBlue.uiColor)
        
        navigationController.setNavigationBarHidden(false, animated: true)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: ColorPalette.gtBlue.uiColor,
            controlColor: .white,
            titleFont: appDiContainer.getFontService().getFont(size: 17, weight: .semibold),
            titleColor: .white,
            isTranslucent: false
        )
    }
    
    private func navigateToDashboard(startingTab: DashboardTabTypeDomainModel = AppFlow.defaultStartingDashboardTab, animatePopToToolsMenu: Bool = false, animateDismissingPresentedView: Bool = false, didCompleteDismissingPresentedView: (() -> Void)? = nil) {
        
        if let dashboard = getDashboardInNavigationStack() {
            
            dashboard.rootView.navigateToTab(startingTab)
        }
        else {
            
            let dashboard = getNewDashboardView(startingTab: startingTab)
            
            navigationController.setViewControllers([dashboard], animated: false)
        }
        
        configureNavBarForDashboard()
        
        closeMenu(animated: false)
        
        onboardingFlow = nil
        languageSettingsFlow = nil
        learnToShareToolFlow = nil
        articleDeepLinkFlow = nil
        tutorialFlow = nil
        lessonFlow = nil
        tractFlow = nil
        articleFlow = nil
        
        navigationController.popToRootViewController(animated: animatePopToToolsMenu)
        
        navigationController.dismissPresented(
            animated: animateDismissingPresentedView,
            completion: didCompleteDismissingPresentedView
        )
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
    
    private func addDeepLinkingObservers() {
        
        guard !isObservingDeepLinking else {
            return
        }
        
        isObservingDeepLinking = true
        
        deepLinkingService.deepLinkObserver.addObserver(self) { [weak self] (optionalDeepLink: ParsedDeepLinkType?) in
            
            guard let deepLink = optionalDeepLink else {
                return
            }
            
            guard let weakSelf = self else {
                return
            }
            
            if !weakSelf.navigationStarted {
                weakSelf.appLaunchedFromDeepLink = deepLink
            }
            else {
                weakSelf.navigate(step: .deepLink(deepLinkType: deepLink))
            }
        }
    }
    
    private func removeDeepLinkingObservers() {
        
        isObservingDeepLinking = false
        deepLinkingService.deepLinkObserver.removeObserver(self)
    }
    
    private func navigateToDeepLink(deepLink: ParsedDeepLinkType) {
        
        switch deepLink {
        
        case .tool(let toolDeepLink):
               
            navigateToDashboard(startingTab: .favorites, animatePopToToolsMenu: false, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: nil)
                        
            navigateToToolFromToolDeepLink(toolDeepLink: toolDeepLink, didCompleteToolNavigation: nil)
            
        case .articleAemUri(let aemUri):
            
            navigateToDashboard(startingTab: .favorites, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: { [weak self] in
                
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
            
        case .lessonsList:
            navigateToDashboard(startingTab: .lessons)
            
        case .favoritedToolsList:
            navigateToDashboard(startingTab: .favorites)
            
        case .allToolsList:
            navigateToDashboard(startingTab: .tools, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: nil)
            
        case .dashboard:
            navigateToDashboard(startingTab: .favorites)
            
        case .onboarding:
            navigateToOnboarding(animated: true)
        }
    }
}

// MARK: - Language Settings

extension AppFlow {
    
    private func navigateToLanguageSettings() {
        
        let languageSettingsFlow = LanguageSettingsFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController
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

// MARK: - Tutorial

extension AppFlow {
    
    private func navigateToTutorial() {
        
        let tutorialFlow = TutorialFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: nil
        )
        
        navigationController.present(tutorialFlow.navigationController, animated: true, completion: nil)
        
        self.tutorialFlow = tutorialFlow
    }
    
    private func dismissTutorial() {
        
        if menuFlow != nil {
            navigateToDashboard(startingTab: .favorites)
            closeMenu(animated: true)
        }
        
        if tutorialFlow != nil {
            navigationController.dismiss(animated: true, completion: nil)
            tutorialFlow = nil
        }
    }
}

// MARK: - Tool Favorites

extension AppFlow {
    
    func getAllFavoriteTools() -> UIViewController {
        
        let viewModel = AllYourFavoriteToolsViewModel(
            flowDelegate: self,
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
        
        let view = AllYourFavoriteToolsView(viewModel: viewModel)
        
        let hostingView = UIHostingController<AllYourFavoriteToolsView>(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTappedFromAllFavoriteTools)
        )
        
        return hostingView
    }
}

// MARK: - Confirm Remove Tool From Favorites

extension AppFlow {
    
    private func getConfirmRemoveToolFromFavoritesAlertView(tool: ToolDomainModel, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?) -> UIViewController {
        
        let viewModel = ConfirmRemoveToolFromFavoritesAlertViewModel(
            tool: tool,
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            didConfirmToolRemovalSubject: didConfirmToolRemovalSubject
        )
        
        let view = ConfirmRemoveToolFromFavoritesAlertView(viewModel: viewModel)
        
        return view.controller
    }
}

// MARK: - Tool Detail

extension AppFlow {
    
    private func getToolDetails(resource: ResourceModel) -> UIViewController {
        
        let viewModel = ToolDetailsViewModel(
            flowDelegate: self,
            resource: resource,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            getToolDetailsMediaUseCase: appDiContainer.domainLayer.getToolDetailsMediaUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getToolLanguagesUseCase: appDiContainer.domainLayer.getToolLanguagesUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            getToolTranslationsFilesUseCase: appDiContainer.domainLayer.getToolTranslationsFilesUseCase(),
            getToolVersionsUseCase: appDiContainer.domainLayer.getToolVersionsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
            
        )
        
        let view = ToolDetailsView(viewModel: viewModel)
        
        let hostingView = UIHostingController<ToolDetailsView>(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(target: self, action: #selector(backTappedFromToolDetails))
        
        return hostingView
    }
    
    @objc private func backTappedFromToolDetails() {
        
        navigate(step: .backTappedFromToolDetails)
    }
}

// MARK: - Learn To Share Tool

extension AppFlow {
    
    private func navigateToLearnToShareTool(resource: ResourceModel) {
        
        let toolTrainingTipsOnboardingViews: ToolTrainingTipsOnboardingViewsService = appDiContainer.getToolTrainingTipsOnboardingViews()
                    
        let toolTrainingTipReachedMaximumViews: Bool = toolTrainingTipsOnboardingViews.getToolTrainingTipReachedMaximumViews(resource: resource)
        
        if !toolTrainingTipReachedMaximumViews {
            
            toolTrainingTipsOnboardingViews.storeToolTrainingTipViewed(resource: resource)
            
            let learnToShareToolFlow = LearnToShareToolFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                resource: resource
            )
            
            navigationController.present(learnToShareToolFlow.navigationController, animated: true, completion: nil)
            
            self.learnToShareToolFlow = learnToShareToolFlow
        }
        else {
            
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
        }
    }
    
    private func dismissLearnToShareToolFlow(completion: (() -> Void)?) {
        
        guard learnToShareToolFlow != nil else {
            completion?()
            return
        }
        
        navigationController.dismissPresented(animated: true, completion: completion)
        learnToShareToolFlow = nil
    }
}

// MARK: - Lesson Evaluation

extension AppFlow {
    
    private func presentLessonEvaluation(lesson: ResourceModel, pageIndexReached: Int) {
        
        let viewModel = LessonEvaluationViewModel(
            flowDelegate: self,
            lesson: lesson,
            pageIndexReached: pageIndexReached,
            lessonEvaluationRepository: appDiContainer.dataLayer.getLessonsEvaluationRepository(),
            lessonFeedbackAnalytics: appDiContainer.getLessonFeedbackAnalytics(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            localization: appDiContainer.dataLayer.getLocalizationServices()
        )
        let view = LessonEvaluationView(viewModel: viewModel)
        
        let modalView = TransparentModalView(flowDelegate: self, modalView: view, closeModalFlowStep: .backgroundTappedFromLessonEvaluation)
        
        navigationController.present(modalView, animated: true, completion: nil)
    }
    
    private func dismissLessonEvaluation() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Setup Parallel Language

extension AppFlow {
    
    private func presentSetupParallelLanguage() {
                    
        let setupParallelLanguageAvailabilityUseCase = appDiContainer.domainLayer.getSetupParallelLanguageAvailabilityUseCase()
        
        let setupParallelLanguageIsAvailable: Bool = setupParallelLanguageAvailabilityUseCase.getSetupParallelLanguageIsAvailable().isAvailable
        
        guard setupParallelLanguageIsAvailable else {
            return
        }
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
            guard let weakSelf = self, weakSelf.navigationController.presentedViewController == nil else {
                return
            }
            
            let appDiContainer: AppDiContainer = weakSelf.appDiContainer
            
            let viewModel = SetupParallelLanguageViewModel(
                flowDelegate: weakSelf,
                localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
                setupParallelLanguageViewedRepository: appDiContainer.dataLayer.getSetupParallelLanguageViewedRepository(),
                getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase()
            )
            let view = SetupParallelLanguageView(viewModel: viewModel)
            
            let modalView = TransparentModalView(flowDelegate: weakSelf, modalView: view, closeModalFlowStep: .backgroundTappedFromSetupParallelLanguage)
            
            weakSelf.navigationController.present(modalView, animated: true, completion: nil)
        }
    }
    
    private func presentParallelLanguage() {
        
        let viewModel = ChooseParallelLanguageListViewModel(
            flowDelegate: self,
            getSettingsLanguagesUseCase: appDiContainer.domainLayer.getSettingsLanguagesUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            userDidSetSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getUserDidSetSettingsParallelLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let view = ChooseParallelLanguageListView(viewModel: viewModel)
        
        let modalView = TransparentModalView(flowDelegate: self, modalView: view,  closeModalFlowStep: .backgroundTappedFromParallelLanguageList)
        
        navigationController.presentedViewController?.present(modalView, animated: true, completion: nil)
    }
    
    private func dismissSetupParallelLanguage() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func dismissParallelLanguage() {
        navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Menu

extension AppFlow {
    
    private func navigateToMenu(animated: Bool) {
        
        let menuFlow: MenuFlow = MenuFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer
        )
        self.menuFlow = menuFlow
        
        rootController.addChildController(child: menuFlow.navigationController)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        let menuView: UIView = menuFlow.navigationController.view
        let appView: UIView = navigationController.view
        
        menuView.frame = CGRect(x: screenWidth * -1, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
        
        if animated {
                                                
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                
                menuView.frame = CGRect(x: 0, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
                appView.frame = CGRect(x: screenWidth, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                                
            }, completion: nil)
        }
        else {
            
            menuView.frame = CGRect(x: 0, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
            appView.frame = CGRect(x: screenWidth, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
        }
    }
    
    private func closeMenu(animated: Bool) {
           
        guard let menuFlow = self.menuFlow else {
            return
        }
        
        menuFlow.navigationController.dismiss(animated: animated, completion: nil)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        let menuView: UIView = menuFlow.navigationController.view
        let appView: UIView = navigationController.view
        
        menuView.frame = CGRect(x: 0, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
        appView.frame = CGRect(x: screenWidth, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                
        if animated {
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                                
                menuView.frame = CGRect(x: screenWidth * -1, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
                appView.frame = CGRect(x: 0, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                
            }, completion: { [weak self] ( finished: Bool) in
                
                menuFlow.navigationController.removeAsChildController()
                self?.menuFlow = nil
            })
        }
        else {
                        
            appView.frame = CGRect(x: 0, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
            
            menuFlow.navigationController.removeAsChildController()
            self.menuFlow = nil
        }
    }
}

// MARK: - UIApplication Life Cycle Notifications

extension AppFlow {
    
    private func addUIApplicationLifeCycleObservers() {
              
        guard !uiApplicationLifeCycleObserversAdded else {
            return
        }
        
        uiApplicationLifeCycleObserversAdded = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUIApplicationLifeCycleNotification(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUIApplicationLifeCycleNotification(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUIApplicationLifeCycleNotification(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func removeUIApplicationLifeCycleObservers() {
        
        guard uiApplicationLifeCycleObserversAdded else {
            return
        }
        
        uiApplicationLifeCycleObserversAdded = false
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func handleUIApplicationLifeCycleNotification(notification: Notification) {
        
        if notification.name == UIApplication.willResignActiveNotification {
            
            resignedActiveDate = Date()
        }
        else if notification.name == UIApplication.didBecomeActiveNotification {
                        
            AppBackgroundState.shared.start(
                getAllFavoritedToolsLatestTranslationFilesUseCase: appDiContainer.domainLayer.getAllFavoritedToolsLatestTranslationFilesUseCase(),
                storeInitialFavoritedToolsUseCase: appDiContainer.domainLayer.getStoreInitialFavoritedToolsUseCase()
            )
            
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
