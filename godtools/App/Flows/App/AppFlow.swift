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
    
    private static let defaultStartingDashboardTab: DashboardTabType = .favorites
    
    private let window: UIWindow
    private let dataDownloader: InitialDataDownloader
    private let followUpsService: FollowUpsService
    private let viewsService: ViewsService
    private let deepLinkingService: DeepLinkingService
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var tutorialFlow: TutorialFlow?
    private var learnToShareToolFlow: LearnToShareToolFlow?
    private var articleDeepLinkFlow: ArticleDeepLinkFlow?
    private var appLaunchedFromDeepLink: ParsedDeepLinkType?
    private var resignedActiveDate: Date?
    private var navigationStarted: Bool = false
    private var observersAdded: Bool = false
    private var appIsInBackground: Bool = false
    private var isObservingDeepLinking: Bool = false
    
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    private var cancellables = Set<AnyCancellable>()
        
    init(appDiContainer: AppDiContainer, window: UIWindow, appDeepLinkingService: DeepLinkingService) {
        
        self.appDiContainer = appDiContainer
        self.window = window
        self.navigationController = UINavigationController()
        self.dataDownloader = appDiContainer.initialDataDownloader
        self.followUpsService = appDiContainer.dataLayer.getFollowUpsService()
        self.viewsService = appDiContainer.viewsService
        self.deepLinkingService = appDeepLinkingService
        
        super.init()
        
        rootController.view.frame = UIScreen.main.bounds
        rootController.view.backgroundColor = .clear
        
        navigationController.view.backgroundColor = .white
        navigationController.setNavigationBarHidden(true, animated: false)
        
        rootController.addChildController(child: navigationController)
        
        addObservers()
        addDeepLinkingObservers()
        
        appDiContainer.firebaseInAppMessaging.setDelegate(delegate: self)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeObservers()
        removeDeepLinkingObservers()
    }

    private func loadInitialData() {
        
        dataDownloader.downloadInitialData()
        
        _ = followUpsService.postFailedFollowUpsIfNeeded()
        
        _ = viewsService.postFailedResourceViewsIfNeeded()
    }
    
    func navigate(step: FlowStep) {

        switch step {
        
        case .appLaunchedFromTerminatedState:
                       
            if let deepLink = appLaunchedFromDeepLink {
                
                appLaunchedFromDeepLink = nil
                navigate(step: .deepLink(deepLinkType: deepLink))
            }
            else if appDiContainer.getOnboardingTutorialAvailability().onboardingTutorialIsAvailable {
                
                navigate(step: .showOnboardingTutorial(animated: false))
            }
            else {
                
                navigateToDashboard()
            }
            
            loadInitialData()
            
            appDiContainer.oktaUserAuthentication.refreshAuthenticationIfAvailable()
            
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
                window.addSubview(loadingView)
                
                navigateToDashboard()
                                
                loadInitialData()
                
                appDiContainer.oktaUserAuthentication.refreshAuthenticationIfAvailable()
                
                UIView.animate(withDuration: 0.4, delay: 1.5, options: .curveEaseOut, animations: {
                    loadingView.alpha = 0
                }, completion: {(finished: Bool) in
                    loadingView.removeFromSuperview()
                })
            }
            
            self.resignedActiveDate = nil
            
        case .deepLink(let deepLink):
            navigateToDeepLink(deepLink: deepLink)
            
        case .toolTappedFromAllTools(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromAllTools(let resource):
            
            navigationController.pushViewController(getToolDetails(resource: resource), animated: true)
                                    
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .lessonTappedFromLessonsList(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .lessonTappedFromFeaturedLessons(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .viewAllFavoriteToolsTappedFromFavoritedTools:
            
            navigationController.pushViewController(getAllFavoriteTools(), animated: true)
            
        case .backTappedFromAllFavoriteTools:
            navigationController.popViewController(animated: true)
            
        case .toolTappedFromFavoritedTools(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromFavoritedTools(let resource):
            
            navigationController.pushViewController(getToolDetails(resource: resource), animated: true)
            
        case .allToolsTappedFromFavoritedTools:
            navigateToDashboard(startingTab: .allTools)
            
        case .backTappedFromToolDetails:
            navigationController.popViewController(animated: true)
            
        case .unfavoriteToolTappedFromFavoritedTools(let resource, let removeHandler):
            
            let handler = CallbackHandler { [weak self] in
                removeHandler.handle()
                self?.navigationController.dismiss(animated: true, completion: nil)
            }
            
            let localizationServices: LocalizationServices = appDiContainer.localizationServices
            let languageSettingsService: LanguageSettingsService = appDiContainer.languageSettingsService
            let resourcesCache: ResourcesCache = appDiContainer.initialDataDownloader.resourcesCache
            
            let toolName: String
            
            if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
                toolName = primaryTranslation.translatedName
            }
            else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
                toolName = englishTranslation.translatedName
            }
            else {
                toolName = resource.name
            }
            
            let title: String = localizationServices.stringForMainBundle(key: "remove_from_favorites_title")
            let message: String = localizationServices.stringForMainBundle(key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: toolName)
            let acceptedTitle: String = localizationServices.stringForMainBundle(key: "yes")
            
            let viewModel = AlertMessageViewModel(
                title: title,
                message: message,
                cancelTitle: localizationServices.stringForMainBundle(key: "no"),
                acceptTitle: acceptedTitle,
                acceptHandler: handler
            )
            
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .articleFlowCompleted(let state):
            
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
                
                let lessonEvaluationRepository: LessonEvaluationRepository = appDiContainer.getLessonsEvaluationRepository()
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
                
                setupNavBar()
                navigationController.popToViewController(dashboardInNavigationStack, animated: true)
            }
            else {
                
                setupNavBar()
                _ = navigationController.popViewController(animated: true)
            }
            
            tractFlow = nil
            
        case .chooseYourOwnAdventureFlowCompleted(let state):
           
            switch state {
            
            case .userClosedTool:
                
                if let dashboardInNavigationStack = getDashboardInNavigationStack() {
                    
                    setupNavBar()
                    navigationController.popToViewController(dashboardInNavigationStack, animated: true)
                }
                else {
                    
                    setupNavBar()
                    _ = navigationController.popViewController(animated: true)
                }
                
                chooseYourOwnAdventureFlow = nil
            }
            
        case .urlLinkTappedFromToolDetail(let url, let exitLink):
            navigateToURL(url: url, exitLink: exitLink)
            
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
                navigateToDashboard(startingTab: .allTools)
                
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
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .closeTappedFromLearnToShareTool(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
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

// MARK: - Add / Remove Observers

extension AppFlow {
    
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
    
    private func getNewDashboardView(startingTab: DashboardTabType?) -> UIHostingController<DashboardView> {
        
        let dashboardViewModel = DashboardViewModel(
            startingTab: startingTab ?? AppFlow.defaultStartingDashboardTab,
            flowDelegate: self,
            initialDataDownloader: appDiContainer.initialDataDownloader,
            localizationServices: appDiContainer.localizationServices,
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            analytics: appDiContainer.analytics,
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getLessonsUseCase: appDiContainer.domainLayer.getLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.getOpInOnboardingBannerEnabledUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getShouldShowLanguageSettingsBarButtonUseCase: appDiContainer.domainLayer.getShouldShowLanguageSettingsBarButtonUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase()
        )
        
        let dashboardView = DashboardView(viewModel: dashboardViewModel)
        let dashboardHostingController = UIHostingController(rootView: dashboardView)
        
        _ = dashboardHostingController.addBarButtonItem(
            to: .left,
            image: ImageCatalog.navMenu.uiImage,
            color: .white,
            target: dashboardViewModel,
            action: #selector(dashboardViewModel.menuTapped)
        )

        dashboardViewModel.shouldShowLanguageSettingsBarButtonItemPublisher
            .receiveOnMain()
            .sink { shouldShowBarButtonItem, barButtonItem in
                
                guard let barButtonItem = barButtonItem else { return }
                
                if shouldShowBarButtonItem {
                    
                    dashboardHostingController.addBarButtonItem(item: barButtonItem, barPosition: .right)
                    
                } else {
                    
                    dashboardHostingController.removeBarButtonItem(item: barButtonItem)
                }
            }
            .store(in: &cancellables)
        
        return dashboardHostingController
    }
    
    private func navigateToDashboard(startingTab: DashboardTabType = AppFlow.defaultStartingDashboardTab, animatePopToToolsMenu: Bool = false, animateDismissingPresentedView: Bool = false, didCompleteDismissingPresentedView: (() -> Void)? = nil) {
        
        if let dashboard = getDashboardInNavigationStack() {
            
            dashboard.rootView.navigateToTab(startingTab)
            setupNavBar()
            navigationController.popToViewController(dashboard, animated: true)
        }
        else {
            
            buildNewDashboard(startingTab: startingTab, animatePopToToolsMenu: animatePopToToolsMenu, animateDismissingPresentedView: animateDismissingPresentedView, didCompleteDismissingPresentedView: didCompleteDismissingPresentedView)
        }
    }
    
    private func setupNavBar() {
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
    
    private func buildNewDashboard(startingTab: DashboardTabType, animatePopToToolsMenu: Bool, animateDismissingPresentedView: Bool, didCompleteDismissingPresentedView: (() -> Void)?) {
        
        let dashboard = getNewDashboardView(startingTab: startingTab)
        
        navigationController.setViewControllers([dashboard], animated: false)
        
        setupNavBar()
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
    
    private func navigateToDeepLink(deepLink: ParsedDeepLinkType) {
        
        switch deepLink {
        
        case .tool(let toolDeepLink):
               
            navigateToDashboard(startingTab: .favorites, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: { [weak self] in
                
                self?.navigateToToolFromToolDeepLink(toolDeepLink: toolDeepLink, didCompleteToolNavigation: nil)
            })
            
        case .article(let articleUri):
            
            navigateToDashboard(startingTab: .favorites, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                
                let articleDeepLinkFlow = ArticleDeepLinkFlow(
                    flowDelegate: weakSelf,
                    appDiContainer: weakSelf.appDiContainer,
                    sharedNavigationController: weakSelf.navigationController,
                    aemUri: articleUri
                )
                
                weakSelf.articleDeepLinkFlow = articleDeepLinkFlow
            })
            
        case .lessonsList:
            navigateToDashboard(startingTab: .lessons)
            
        case .favoritedToolsList:
            navigateToDashboard(startingTab: .favorites)
            
        case .allToolsList:
            navigateToDashboard(startingTab: .allTools, animateDismissingPresentedView: false, didCompleteDismissingPresentedView: nil)
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
        
        let viewModel = AllFavoriteToolsViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            localizationServices: appDiContainer.localizationServices,
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            flowDelegate: self,
            analytics: appDiContainer.analytics
        )
        
        let view = AllFavoriteToolsView(viewModel: viewModel)
        
        let hostingView = UIHostingController<AllFavoriteToolsView>(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(target: self, action: #selector(backTappedFromAllFavoriteTools))
        
        return hostingView
    }
    
    @objc private func backTappedFromAllFavoriteTools() {
        
        navigate(step: .backTappedFromAllFavoriteTools)
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
            addToolToFavoritesUseCase: appDiContainer.domainLayer.getAddToolToFavoritesUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getToolLanguagesUseCase: appDiContainer.domainLayer.getToolLanguagesUseCase(),
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics,
            getToolTranslationsFilesUseCase: appDiContainer.domainLayer.getToolTranslationsFilesUseCase(),
            getToolVersionsUseCase: appDiContainer.domainLayer.getToolVersionsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase()
            
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
    
    private func dismissLearnToShareToolFlow() {
        
        guard learnToShareToolFlow != nil else {
            return
        }
        
        navigationController.dismissPresented(animated: true, completion: nil)
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
            lessonEvaluationRepository: appDiContainer.getLessonsEvaluationRepository(),
            lessonFeedbackAnalytics: appDiContainer.getLessonFeedbackAnalytics(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            localization: appDiContainer.localizationServices
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
                            
        guard appDiContainer.getSetupParallelLanguageAvailability().setupParallelLanguageIsAvailable else {
            return
        }
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
            guard let weakSelf = self, weakSelf.navigationController.presentedViewController == nil else {
                return
            }
            
            let appDiContainer: AppDiContainer = weakSelf.appDiContainer
            
            let viewModel = SetupParallelLanguageViewModel(
                flowDelegate: weakSelf,
                localizationServices: appDiContainer.localizationServices,
                getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
                setupParallelLanguageAvailability: appDiContainer.getSetupParallelLanguageAvailability()
            )
            let view = SetupParallelLanguageView(viewModel: viewModel)
            
            let modalView = TransparentModalView(flowDelegate: weakSelf, modalView: view, closeModalFlowStep: .backgroundTappedFromSetupParallelLanguage)
            
            weakSelf.navigationController.present(modalView, animated: true, completion: nil)
        }
    }
    
    private func presentParallelLanguage() {
        
        let viewModel = ParallelLanguageListViewModel(
            flowDelegate: self,
            getSettingsLanguagesUseCase: appDiContainer.domainLayer.getSettingsLanguagesUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            userDidSetSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getUserDidSetSettingsParallelLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let view = ParallelLanguageListView(viewModel: viewModel)
        
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
           
        guard let menuFlow = self.menuFlow else {
            return
        }
        
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

// MARK: - Notifications

extension AppFlow {
    
    @objc private func handleNotification(notification: Notification) {
        
        if notification.name == UIApplication.willResignActiveNotification {
            
            resignedActiveDate = Date()
        }
        else if notification.name == UIApplication.didBecomeActiveNotification {
            
            appDiContainer.dataLayer.getLaunchCountRepository().incrementLaunchCount()
            
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
