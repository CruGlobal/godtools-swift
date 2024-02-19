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
    
    private let resourcesRepository: ResourcesRepository
    private let toolLanguageDownloader: ToolLanguageDownloader
    private let followUpsService: FollowUpsService
    private let resourceViewsService: ResourceViewsService
    private let deepLinkingService: DeepLinkingService
    private let inAppMessaging: FirebaseInAppMessaging
    
    private var onboardingFlow: OnboardingFlow?
    private var menuFlow: MenuFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    private var tutorialFlow: TutorialFlow?
    private var learnToShareToolFlow: LearnToShareToolFlow?
    private var articleDeepLinkFlow: ArticleDeepLinkFlow?
    private var appLaunchedFromDeepLink: ParsedDeepLinkType?
    private var resignedActiveDate: Date?
    private var navigationStarted: Bool = false
    private var uiApplicationLifeCycleObserversAdded: Bool = false
    private var appIsInBackground: Bool = false
    private var isObservingDeepLinking: Bool = false
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
        
    let appDiContainer: AppDiContainer
    let rootController: AppRootController = AppRootController(nibName: nil, bundle: nil)
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
            
    init(appDiContainer: AppDiContainer, appDeepLinkingService: DeepLinkingService) {
        
        let navigationBarAppearance = AppNavigationBarAppearance(
            backgroundColor: ColorPalette.gtBlue.uiColor,
            controlColor: .white,
            titleFont: appDiContainer.getFontService().getFont(size: 17, weight: .semibold),
            titleColor: .white,
            isTranslucent: false
        )
        
        self.appDiContainer = appDiContainer
        self.navigationController = AppNavigationController(navigationBarAppearance: navigationBarAppearance)
        self.resourcesRepository = appDiContainer.dataLayer.getResourcesRepository()
        self.toolLanguageDownloader = appDiContainer.feature.appLanguage.dataLayer.getToolLanguageDownloader()
        self.followUpsService = appDiContainer.dataLayer.getFollowUpsService()
        self.resourceViewsService = appDiContainer.dataLayer.getResourceViewsService()
        self.deepLinkingService = appDeepLinkingService
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
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
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
                  
            appDiContainer.feature.onboarding.domainLayer.getOnboardingTutorialIsAvailableUseCase()
                .getAvailablePublisher()
                .receive(on: DispatchQueue.main)
                .first()
                .sink(receiveValue: { [weak self] (onboardingTutorialIsAvailable: Bool) in
                   
                    self?.launchAppFromTerminatedState(onboardingTutorialIsAvailable: onboardingTutorialIsAvailable)
                })
                .store(in: &cancellables)
                        
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
            
        case .toolCategoryFilterTappedFromTools(let categoryFilterSelectionPublisher, let selectedLanguage):
            navigationController.pushViewController(getToolCategoryFilterSelection(categoryFilterSelectionPublisher: categoryFilterSelectionPublisher, selectedLanguage: selectedLanguage), animated: true)
            
        case .toolLanguageFilterTappedFromTools(let languageFilterSelectionPublisher, let selectedCategory):
            navigationController.pushViewController(getToolLanguageFilterSelection(toolFilterLanguageSelectionPublisher: languageFilterSelectionPublisher, selectedCategory: selectedCategory), animated: true)
        
        case .categoryTappedFromToolCategoryFilter:
            navigationController.popViewController(animated: true)
            
        case .languageTappedFromToolLanguageFilter:
            navigationController.popViewController(animated: true)

        case .backTappedFromToolCategoryFilter:
            navigationController.popViewController(animated: true)
            
        case .backTappedFromToolLanguageFilter:
            navigationController.popViewController(animated: true)
            
        case .spotlightToolTappedFromTools(let spotlightTool, let toolFilterLanguage):
            
            let toolDetails = getToolDetails(
                toolId: spotlightTool.dataModelId,
                parallelLanguage: toolFilterLanguage?.language?.localeIdentifier,
                selectedLanguageIndex: 1
            )
            
            navigationController.pushViewController(toolDetails, animated: true)
                        
        case .toolTappedFromTools(let tool, let toolFilterLanguage):
            
            let toolDetails = getToolDetails(
                toolId: tool.dataModelId,
                parallelLanguage: toolFilterLanguage?.language?.localeIdentifier,
                selectedLanguageIndex: 1
            )
            
            navigationController.pushViewController(toolDetails, animated: true)
                                    
        case .openToolTappedFromToolDetails(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            navigateToTool(toolDataModelId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: false)
            
        case .lessonTappedFromLessonsList(let lessonListItem):
            navigateToToolInAppLanguage(toolDataModelId: lessonListItem.dataModelId, trainingTipsEnabled: false)
            
        case .featuredLessonTappedFromFavorites(let featuredLesson):
            navigateToToolInAppLanguage(toolDataModelId: featuredLesson.dataModelId, trainingTipsEnabled: false)
            
        case .viewAllFavoriteToolsTappedFromFavorites:
            navigationController.pushViewController(getAllFavoriteTools(), animated: true)
            
        case .toolDetailsTappedFromFavorites(let tool):
            
            let toolDetails = getToolDetails(
                toolId: tool.dataModelId,
                parallelLanguage: nil,
                selectedLanguageIndex: nil
            )
            
            navigationController.pushViewController(toolDetails, animated: true)
        
        case .openToolTappedFromFavorites(let tool):
            navigateToToolInAppLanguage(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false)
            
        case .toolTappedFromFavorites(let tool):
            navigateToToolInAppLanguage(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false)
            
        case .unfavoriteToolTappedFromFavorites(let tool):
            
            presentConfirmRemoveToolFromFavoritesAlertView(
                toolId: tool.dataModelId,
                didConfirmToolRemovalSubject: nil, 
                animated: true
            )
            
        case .goToToolsTappedFromFavorites:
            navigateToDashboard(startingTab: .tools)
            
        case .backTappedFromAllYourFavoriteTools:
            navigationController.popViewController(animated: true)
            
        case .toolDetailsTappedFromAllYourFavoriteTools(let tool):

            let toolDetails = getToolDetails(
                toolId: tool.dataModelId,
                parallelLanguage: nil,
                selectedLanguageIndex: nil
            )
            
            navigationController.pushViewController(toolDetails, animated: true)
        
        case .openToolTappedFromAllYourFavoriteTools(let tool):
            navigateToToolInAppLanguage(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false)
            
        case .toolTappedFromAllYourFavoritedTools(let tool):
            navigateToToolInAppLanguage(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false)
        
        case .unfavoriteToolTappedFromAllYourFavoritedTools(let tool, let didConfirmToolRemovalSubject):
            
            presentConfirmRemoveToolFromFavoritesAlertView(
                toolId: tool.dataModelId,
                didConfirmToolRemovalSubject: didConfirmToolRemovalSubject,
                animated: true
            )
            
        case .backTappedFromToolDetails:
            configureNavBarForDashboard()
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
                
                let getLessonEvaluatedUseCase: GetLessonEvaluatedUseCase = appDiContainer.feature.lessonEvaluation.domainLayer.getLessonEvaluatedUseCase()
                
                getLessonEvaluatedUseCase.getEvaluatedPublisher(lesson: lesson)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] (lessonEvaluated: Bool) in
                        
                        if highestPageNumberViewed > 2 && !lessonEvaluated {
                            self?.presentLessonEvaluation(lesson: lesson, pageIndexReached: highestPageNumberViewed)
                        }
                    }
                    .store(in: &cancellables)
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
            
        case .urlLinkTappedFromToolDetail(let url, let screenName, let siteSection, let siteSubSection, let contentLanguage, let contentLanguageSecondary):
            navigateToURL(url: url, screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, contentLanguage: contentLanguage, contentLanguageSecondary: contentLanguageSecondary)
            
        case .showOnboardingTutorial(let animated):
            navigateToOnboarding(animated: animated)
            
        case .onboardingFlowCompleted(let onboardingFlowCompletedState):
            
            switch onboardingFlowCompletedState {
            
            case .completed:
                navigateToDashboard()
                
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
            
        case .buttonWithUrlTappedFromFirebaseInAppMessage(let url):
                        
            let didParseDeepLinkFromUrl: Bool = deepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
            
            if !didParseDeepLinkFromUrl {
                UIApplication.shared.open(url)
            }
            
        case .learnToShareToolTappedFromToolDetails(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            navigateToLearnToShareTool(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex)
            
        case .continueTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            dismissLearnToShareToolFlow {
                self.navigateToTool(toolDataModelId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: true)
            }
            
        case .closeTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            dismissLearnToShareToolFlow {
                self.navigateToTool(toolDataModelId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: true)
            }
            
        case .closeTappedFromLessonEvaluation:
            dismissLessonEvaluation()
            
        case .sendFeedbackTappedFromLessonEvaluation:
            dismissLessonEvaluation()
        
        case .backgroundTappedFromLessonEvaluation:
            dismissLessonEvaluation()
                        
        default:
            break
        }
    }
}

// MARK: - Launch

extension AppFlow {
    
    private func launchAppFromTerminatedState(onboardingTutorialIsAvailable: Bool) {
        
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
    }
    
    private func loadInitialData() {
        
        resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsIgnoringErrorPublisher()
            .flatMap({ _ -> AnyPublisher<Void, Never> in
                
                return self.toolLanguageDownloader
                    .syncDownloadedLanguagesPublisher()
                    .eraseToAnyPublisher()
            })
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        _ = followUpsService.postFailedFollowUpsIfNeeded()
        
        _ = resourceViewsService.postFailedResourceViewsIfNeeded()
        
        let authenticateUser: AuthenticateUserInterface = appDiContainer.feature.accountCreation.dataLayer.getAuthenticateUserInterface()
        
        authenticateUser.renewAuthenticationPublisher()
            .sink { finished in

            } receiveValue: { authUser in

            }
            .store(in: &cancellables)
        
        let translatedLanguageNameRepositorySync: TranslatedLanguageNameRepositorySync = appDiContainer.dataLayer.getTranslatedLanguageNameRepositorySync()
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<Void, Never> in
                
                return translatedLanguageNameRepositorySync
                    .syncTranslatedLanguageNamesPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .sink { _ in
                
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

// MARK: - Dashboard

extension AppFlow {

    private func getDashboardInNavigationStack() -> AppHostingController<DashboardView>? {
        
        for viewController in navigationController.viewControllers {
            if let dashboardView = viewController as? AppHostingController<DashboardView> {
                return dashboardView
            }
        }
        
        return nil
    }
    
    private func getNewDashboardView(startingTab: DashboardTabTypeDomainModel?) -> UIViewController {
                
        let viewModel = DashboardViewModel(
            startingTab: startingTab ?? AppFlow.defaultStartingDashboardTab,
            flowDelegate: self,
            dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies(
                appDiContainer: appDiContainer,
                flowDelegate: self
            ),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewDashboardUseCase: appDiContainer.feature.dashboard.domainLayer.getViewDashboardUseCase()
        )
                
        let view = DashboardView(viewModel: viewModel)
        
        let menuButton = AppMenuBarItem(
            color: .white,
            target: viewModel,
            action: #selector(viewModel.menuTapped),
            accessibilityIdentifier: nil
        )
        
        let languageSettingsButton = AppLanguageSettingsBarItem(
            color: .white,
            target: viewModel,
            action: #selector(viewModel.languageSettingsTapped),
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesLanguagesSettingsButton.eraseToAnyPublisher()
        )
        
        let hostingController = AppHostingController<DashboardView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [menuButton],
                trailingItems: [languageSettingsButton]
            )
        )
    
        return hostingController
    }
    
    private func configureNavBarForDashboard() {
        
        AppDelegate.setWindowBackgroundColorForStatusBarColor(color: ColorPalette.gtBlue.uiColor)
                
        navigationController.resetNavigationBarAppearance()
        
        navigationController.setSemanticContentAttribute(semanticContentAttribute: ApplicationLayout.shared.currentDirection.semanticContentAttribute)
        
        navigationController.setLayoutDirectionPublisherToApplicationLayout()
    }
    
    private func navigateToDashboard(startingTab: DashboardTabTypeDomainModel = AppFlow.defaultStartingDashboardTab, animatePopToToolsMenu: Bool = false, animateDismissingPresentedView: Bool = false, didCompleteDismissingPresentedView: (() -> Void)? = nil) {
        
        if let dashboard = getDashboardInNavigationStack() {
            
            dashboard.rootView.navigateToTab(tab: startingTab)
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
            
        case .onboarding(let appLanguage):
            
            let userAppLanguageCache: RealmUserAppLanguageCache = appDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageCache()
            
            userAppLanguageCache.storeLanguage(languageId: appLanguage)
            
            navigateToOnboarding(animated: true)
        }
    }
}

// MARK: - Tool

extension AppFlow {
    
    private func navigateToToolInAppLanguage(toolDataModelId: String, trainingTipsEnabled: Bool) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        let languageIds: Set<String>
        
        if let appLanguageModel = languagesRepository.getLanguage(code: appLanguage) {
            languageIds = [appLanguageModel.id]
        }
        else {
            languageIds = Set()
        }
        
        navigateToTool(toolDataModelId: toolDataModelId, languageIds: languageIds, selectedLanguageIndex: nil, trainingTipsEnabled: trainingTipsEnabled)
    }
    
    private func navigateToTool(toolDataModelId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        var languageIds: Set<String> = Set()
        
        if let languageModel = languagesRepository.getLanguage(code: primaryLanguage) {
            languageIds.insert(languageModel.id)
        }
        
        if let parallelLanguage = parallelLanguage, let languageModel = languagesRepository.getLanguage(code: parallelLanguage) {
            languageIds.insert(languageModel.id)
        }
        
        navigateToTool(toolDataModelId: toolDataModelId, languageIds: languageIds, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: trainingTipsEnabled)
    }
        
    private func navigateToTool(toolDataModelId: String, languageIds: Set<String>, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        let openToolInLanguages: Set<String>
        
        if languageIds.isEmpty, let englishLanguage = languagesRepository.getLanguage(code: LanguageCodeDomainModel.english.rawValue) {
            
            openToolInLanguages = [englishLanguage.id]
        }
        else {
            
            openToolInLanguages = languageIds
        }
        
        navigateToTool(
            resourceId: toolDataModelId,
            languageIds: openToolInLanguages,
            liveShareStream: nil,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: nil
        )
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
            viewAllYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getViewAllYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = AllYourFavoriteToolsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<AllYourFavoriteToolsView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
}

// MARK: - Confirm Remove Tool From Favorites

extension AppFlow {
    
    private func getConfirmRemoveToolFromFavoritesAlertView(toolId: String, domainModel: ViewConfirmRemoveToolFromFavoritesDomainModel, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?) -> UIViewController {
        
        let viewModel = ConfirmRemoveToolFromFavoritesAlertViewModel(
            toolId: toolId,
            viewConfirmRemoveToolFromFavoritesDomainModel: domainModel,
            removeFavoritedToolUseCase: appDiContainer.feature.favorites.domainLayer.getRemoveFavoritedToolUseCase(),
            didConfirmToolRemovalSubject: didConfirmToolRemovalSubject
        )
        
        let view = ConfirmRemoveToolFromFavoritesAlertView(viewModel: viewModel)
        
        return view.controller
    }
    
    private func presentConfirmRemoveToolFromFavoritesAlertView(toolId: String, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?, animated: Bool) {
        
        appDiContainer.feature.favorites.domainLayer
            .getViewConfirmRemoveToolFromFavoritesUseCase()
            .viewPublisher(toolId: toolId, appLanguage: appLanguage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewConfirmRemoveToolFromFavoritesDomainModel) in
                
                guard let weakSelf = self else {
                    return
                }
                
                let view = weakSelf.getConfirmRemoveToolFromFavoritesAlertView(
                    toolId: toolId,
                    domainModel: domainModel,
                    didConfirmToolRemovalSubject: didConfirmToolRemovalSubject
                )
                
                weakSelf.navigationController.present(view, animated: animated)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Tool Filter Selection

extension AppFlow {
    
    private func getToolCategoryFilterSelection(categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>, selectedLanguage: LanguageFilterDomainModel) -> UIViewController {
        
        let viewModel = ToolFilterCategorySelectionViewModel(
            getToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterCategoriesUseCase(),
            searchToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSearchToolFilterCategoriesUseCase(),
            storeUserFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getStoreUserFiltersUseCase(),
            categoryFilterSelectionPublisher: categoryFilterSelectionPublisher,
            selectedLanguage: selectedLanguage,
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewSearchBarUseCase: appDiContainer.domainLayer.getViewSearchBarUseCase(),
            flowDelegate: self
         )
        
        let view = ToolFilterCategorySelectionView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backButtonTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<ToolFilterCategorySelectionView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
                        
        return hostingView
    }
    
    private func getToolLanguageFilterSelection(toolFilterLanguageSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>, selectedCategory: CategoryFilterDomainModel) -> UIViewController {
        
        let viewModel = ToolFilterLanguageSelectionViewModel(
            getToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterLanguagesUseCase(),
            searchToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSearchToolFilterLanguagesUseCase(),
            storeUserFilterUseCase: appDiContainer.feature.toolsFilter.domainLayer.getStoreUserFiltersUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewSearchBarUseCase: appDiContainer.domainLayer.getViewSearchBarUseCase(),
            languageFilterSelectionPublisher: toolFilterLanguageSelectionPublisher,
            selectedCategory: selectedCategory,
            flowDelegate: self
        )
        
        let view = ToolFilterLanguageSelectionView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backButtonTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<ToolFilterLanguageSelectionView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
                        
        return hostingView
    }
}

// MARK: - Tool Detail

extension AppFlow {
    
    private func getToolDetails(toolId: String, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?) -> UIViewController {
        
        let viewModel = ToolDetailsViewModel(
            flowDelegate: self,
            toolId: toolId,
            primaryLanguage: appLanguage,
            parallelLanguage: parallelLanguage,
            selectedLanguageIndex: selectedLanguageIndex,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolDetailsUseCase: appDiContainer.feature.toolDetails.domainLayer.getViewToolDetailsUseCase(),
            getToolDetailsMediaUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsMediaUseCase(),
            getToolDetailsLearnToShareToolIsAvailableUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsLearnToShareToolIsAvailableUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleFavoritedToolUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ToolDetailsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<ToolDetailsView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
}

// MARK: - Learn To Share Tool

extension AppFlow {
    
    private func navigateToLearnToShareTool(toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?) {
        
        let toolTrainingTipsOnboardingViews: ToolTrainingTipsOnboardingViewsService = appDiContainer.getToolTrainingTipsOnboardingViews()
                    
        let toolTrainingTipReachedMaximumViews: Bool = toolTrainingTipsOnboardingViews.getToolTrainingTipReachedMaximumViews(toolId: toolId, primaryLanguage: primaryLanguage)
        
        if !toolTrainingTipReachedMaximumViews {
            
            toolTrainingTipsOnboardingViews.storeToolTrainingTipViewed(toolId: toolId, primaryLanguage: primaryLanguage)
            
            let learnToShareToolFlow = LearnToShareToolFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                toolId: toolId,
                toolPrimaryLanguage: primaryLanguage,
                toolParallelLanguage: parallelLanguage,
                toolSelectedLanguageIndex: selectedLanguageIndex
            )
            
            navigationController.present(learnToShareToolFlow.navigationController, animated: true, completion: nil)
            
            self.learnToShareToolFlow = learnToShareToolFlow
        }
        else {
            
            navigateToTool(
                toolDataModelId: toolId,
                primaryLanguage: primaryLanguage,
                parallelLanguage: parallelLanguage,
                selectedLanguageIndex: selectedLanguageIndex,
                trainingTipsEnabled: true
            )
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
    
    private func presentLessonEvaluation(lesson: ToolDomainModel, pageIndexReached: Int) {
        
        let viewModel = LessonEvaluationViewModel(
            flowDelegate: self,
            lesson: lesson,
            pageIndexReached: pageIndexReached,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLessonEvaluationInterfaceStringsUseCase: appDiContainer.feature.lessonEvaluation.domainLayer.getLessonEvaluationInterfaceStringsUseCase(),
            evaluateLessonUseCase: appDiContainer.feature.lessonEvaluation.domainLayer.getEvaluateLessonUseCase(),
            cancelLessonEvaluationUseCase: appDiContainer.feature.lessonEvaluation.domainLayer.getCancelLessonEvaluationUseCase()
        )
        
        let view = LessonEvaluationView(
            viewModel: viewModel
        )
        
        let hostingView = AppHostingController<LessonEvaluationView>(rootView: view, navigationBar: nil)
        
        let overlayNavigationController = OverlayNavigationController(
            rootView: hostingView,
            hidesNavigationBar: true,
            navigationBarAppearance: nil
        )
        
        navigationController.present(overlayNavigationController, animated: true)
    }
    
    private func dismissLessonEvaluation() {
        navigationController.dismiss(animated: true, completion: nil)
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
        
        let menuViewStartingX: CGFloat
        let menuViewEndingX: CGFloat = 0
        let appViewEndingX: CGFloat
        
        switch ApplicationLayout.shared.currentDirection {
       
        case .leftToRight:
            menuViewStartingX = screenWidth * -1
            appViewEndingX = screenWidth
            
        case .rightToLeft:
            menuViewStartingX = screenWidth
            appViewEndingX = screenWidth * -1
        }
        
        menuView.frame = CGRect(x: menuViewStartingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
        
        if animated {
                                                
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                
                menuView.frame = CGRect(x: menuViewEndingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
                appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                                
            }, completion: nil)
        }
        else {
            
            menuView.frame = CGRect(x: menuViewEndingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
            appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
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
        
        let menuViewStartingX: CGFloat = 0
        let menuViewEndingX: CGFloat
        let appViewStartingX: CGFloat
        let appViewEndingX: CGFloat = 0
        
        switch ApplicationLayout.shared.currentDirection {
       
        case .leftToRight:
            menuViewEndingX = screenWidth * -1
            appViewStartingX = screenWidth
            
        case .rightToLeft:
            menuViewEndingX = screenWidth
            appViewStartingX = screenWidth * -1
        }
        
        menuView.frame = CGRect(x: menuViewStartingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
        appView.frame = CGRect(x: appViewStartingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                
        if animated {
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                                
                menuView.frame = CGRect(x: menuViewEndingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
                appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                
            }, completion: { [weak self] ( finished: Bool) in
                
                menuFlow.navigationController.removeAsChildController()
                self?.menuFlow = nil
            })
        }
        else {
                        
            appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
            
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
                        
            AppBackgroundState.shared.start(appDiContainer: appDiContainer)
            
            ApplicationLayout.shared.configure(appLanguageFeatureDiContainer: appDiContainer.feature.appLanguage)
            
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
