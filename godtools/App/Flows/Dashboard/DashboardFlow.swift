//
//  DashboardFlow.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import Combine

class DashboardFlow: NSObject, Flow, ToolNavigationFlow {
        
    private let dashboardTabObserver: CurrentValueSubject<DashboardTabTypeDomainModel, Never>
    private let startingTab: DashboardTabTypeDomainModel = .favorites
    
    private var tutorialFlow: TutorialFlow?
    private var learnToShareToolFlow: LearnToShareToolFlow?
    private var cancellables: Set<AnyCancellable> = Set()
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    let rootController: AppRootController
    
    var menuFlow: MenuFlow?
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    init(appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, rootController: AppRootController) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.rootController = rootController
        
        dashboardTabObserver = CurrentValueSubject(startingTab)
        
        super.init()
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
    }
    
    func navigate(step: FlowStep) {
     
        navigationController.delegate = self
        
        switch step {
                        
        case .menuTappedFromTools:
            navigateToMenu(animated: true)
            
        case .doneTappedFromMenu:
            closeMenu(animated: true)
            
        case .lessonTappedFromLessonsList(let lessonListItem, let languageFilter):
            navigateToLesson(lessonListItem: lessonListItem, languageFilter: languageFilter, toolOpenedFrom: .dashboardLessons)
            
        case .lessonLanguageFilterTappedFromLessons:
            navigationController.pushViewController(getLessonLanguageFilterSelection(), animated: true)
            
        case .backTappedFromLessonLanguageFilter:
            navigationController.popViewController(animated: true)
            
        case .languageTappedFromLessonLanguageFilter:
            navigationController.popViewController(animated: true)
            
        case .featuredLessonTappedFromFavorites(let featuredLesson):
            navigateToToolInAppLanguage(toolDataModelId: featuredLesson.dataModelId, trainingTipsEnabled: false, toolOpenedFrom: .dashboardFavoritesFeaturedLesson)
            
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
            navigateToToolWithUserToolLanguageSettingsApplied(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false, toolOpenedFrom: .dashboardFavoritesFavoritedTool)
            
        case .toolTappedFromFavorites(let tool):
            navigateToToolWithUserToolLanguageSettingsApplied(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false, toolOpenedFrom: .dashboardFavoritesFavoritedTool)
            
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
        
        case .openTutorialTappedFromTools:
            navigateToTutorial()
            
        case .tutorialFlowCompleted( _):
            dismissTutorial()
        
        case .openToolTappedFromAllYourFavoriteTools(let tool):
            navigateToToolWithUserToolLanguageSettingsApplied(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false, toolOpenedFrom: .dashboardFavoritesFavoritedTool)
            
        case .toolTappedFromAllYourFavoritedTools(let tool):
            navigateToToolWithUserToolLanguageSettingsApplied(toolDataModelId: tool.dataModelId, trainingTipsEnabled: false, toolOpenedFrom: .dashboardFavoritesFavoritedTool)
            
        case .unfavoriteToolTappedFromAllYourFavoritedTools(let tool, let didConfirmToolRemovalSubject):
            
            presentConfirmRemoveToolFromFavoritesAlertView(
                toolId: tool.dataModelId,
                didConfirmToolRemovalSubject: didConfirmToolRemovalSubject,
                animated: true
            )
            
        case .toolCategoryFilterTappedFromTools:
            navigationController.pushViewController(getToolCategoryFilterSelection(), animated: true)
            
        case .toolLanguageFilterTappedFromTools:
            navigationController.pushViewController(getToolLanguageFilterSelection(), animated: true)
        
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
                parallelLanguage: toolFilterLanguage?.languageLocale,
                selectedLanguageIndex: 1
            )
            
            navigationController.pushViewController(toolDetails, animated: true)
                        
        case .toolTappedFromTools(let tool, let toolFilterLanguage):
            
            let resourcesRepository: ResourcesRepository = appDiContainer.dataLayer.getResourcesRepository()
            let primaryLanguage: AppLanguageDomainModel?
            let parallelLanguage: AppLanguageDomainModel?
            
            if let toolResource = resourcesRepository.persistence.getObject(id: tool.dataModelId),
               toolResource.resourceTypeEnum == .article {
                
                parallelLanguage = nil
                
                if let toolsFilterLanguageId = toolFilterLanguage?.languageDataModelId,
                   let toolFilterLanguageLocale = toolFilterLanguage?.languageLocale,
                   toolResource.supportsLanguage(languageId: toolsFilterLanguageId) {
                    
                    primaryLanguage = toolFilterLanguageLocale
                }
                else {
                    
                    primaryLanguage = appLanguage
                }
            }
            else {
                primaryLanguage = nil
                parallelLanguage = toolFilterLanguage?.languageLocale
            }
            
            let toolDetails = getToolDetails(
                toolId: tool.dataModelId,
                parallelLanguage: parallelLanguage,
                selectedLanguageIndex: 1,
                primaryLanguage: primaryLanguage
            )
            
            navigationController.pushViewController(toolDetails, animated: true)
            
        case .openToolTappedFromToolDetails(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            
            if dashboardTabObserver.value == .favorites {
                
                navigateToToolWithUserToolLanguageSettingsApplied(toolDataModelId: toolId, trainingTipsEnabled: false, toolOpenedFrom: .dashboardFavoritesFavoritedTool)
            } else {
                
                navigateToTool(toolDataModelId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: false, toolOpenedFrom: .dashboardTools)
            }
            
        case .backTappedFromToolDetails:
            navigationController.popViewController(animated: true)
            
        case .urlLinkTappedFromToolDetails(let url, let screenName, let siteSection, let siteSubSection, let contentLanguage, let contentLanguageSecondary):
            navigateToURL(url: url, screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, appLanguage: appLanguage, contentLanguage: contentLanguage, contentLanguageSecondary: contentLanguageSecondary)
            
        case .learnToShareToolTappedFromToolDetails(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            navigateToLearnToShareTool(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, toolOpenedFrom: .learnToShare)
            
        case .startTrainingTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            dismissLearnToShareToolFlow {
                self.navigateToTool(toolDataModelId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: true, toolOpenedFrom: .learnToShare)
            }
            
        case .closeTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            dismissLearnToShareToolFlow {
                self.navigateToTool(toolDataModelId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: true, toolOpenedFrom: .learnToShare)
            }
            
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
            
            case .userClosedLesson(let lessonId, let highestPageNumberViewed):
                
                let getLessonEvaluatedUseCase: GetLessonEvaluatedUseCase = appDiContainer.feature.lessonEvaluation.domainLayer.getLessonEvaluatedUseCase()
                
                getLessonEvaluatedUseCase
                    .execute(lessonId: lessonId)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] (lessonEvaluated: Bool) in
                        
                        if highestPageNumberViewed > 2 && !lessonEvaluated {
                            self?.presentLessonEvaluation(lessonId: lessonId, pageIndexReached: highestPageNumberViewed)
                        }
                    }
                    .store(in: &cancellables)
            }
            
        case .closeTappedFromLessonEvaluation:
            dismissLessonEvaluation()
            
        case .sendFeedbackTappedFromLessonEvaluation:
            dismissLessonEvaluation()
        
        case .backgroundTappedFromLessonEvaluation:
            dismissLessonEvaluation()
            
        case .tractFlowCompleted(let state):
            
            guard tractFlow != nil else {
                return
            }
            
            if state == .userClosedTractToLessonsList {
                
                navigateToDashboard(startingTab: .lessons, animatePopToToolsMenu: true)
            }
            else if let dashboardInNavigationStack = getDashboardInNavigationStack() {
                
                navigationController.popToViewController(dashboardInNavigationStack, animated: true)
            }
            else {
                
                _ = navigationController.popViewController(animated: true)
            }
            
            tractFlow = nil
            
        case .chooseYourOwnAdventureFlowCompleted(let state):
           
            switch state {
            
            case .userClosedTool:
                
                if let dashboardInNavigationStack = getDashboardInNavigationStack() {
                    
                    navigationController.popToViewController(dashboardInNavigationStack, animated: true)
                }
                else {
                    
                    _ = navigationController.popViewController(animated: true)
                }
                
                chooseYourOwnAdventureFlow = nil
            }
            
        default:
            break
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension DashboardFlow: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isDashboard: Bool = viewController is AppHostingController<DashboardView>
        let hidesNavigationBar: Bool = isDashboard
        
        if isDashboard {
            configureNavBarForDashboard()
        }
        
        navigationController.setNavigationBarHidden(hidesNavigationBar, animated: false)
    }
}

// MARK: - Dashboard

extension DashboardFlow {
    
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
            startingTab: startingTab ?? self.startingTab,
            flowDelegate: self,
            dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies(
                appDiContainer: appDiContainer,
                flowDelegate: self
            ),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewDashboardUseCase: appDiContainer.feature.dashboard.domainLayer.getViewDashboardUseCase(),
            dashboardTabObserver: dashboardTabObserver
        )
                
        let view = DashboardView(viewModel: viewModel)
            
        let hostingController = AppHostingController<DashboardView>(
            rootView: view,
            navigationBar: nil
        )
    
        return hostingController
    }
    
    private func configureNavBarForDashboard() {
        
        GodToolsSceneDelegate.setWindowBackgroundColorForStatusBarColor(color: AppFlow.defaultNavBarColor)
                
        navigationController.resetNavigationBarAppearance()
        
        navigationController.setSemanticContentAttribute(semanticContentAttribute: ApplicationLayout.shared.currentDirection.semanticContentAttribute)
        
        navigationController.setLayoutDirectionPublisherToApplicationLayout()
    }
    
    func navigateToDashboard(startingTab: DashboardTabTypeDomainModel? = nil, animatePopToToolsMenu: Bool = false, animateDismissingPresentedView: Bool = false, didCompleteDismissingPresentedView: (() -> Void)? = nil) {
        
        let startingTab: DashboardTabTypeDomainModel = startingTab ?? self.startingTab
        
        if let dashboard = getDashboardInNavigationStack() {
            
            dashboard.rootView.navigateToTab(tab: startingTab)
        }
        else {
            
            let dashboard = getNewDashboardView(startingTab: startingTab)
            
            navigationController.setViewControllers([dashboard], animated: false)
        }
                
        closeMenu(animated: false)
        
        learnToShareToolFlow = nil
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

// MARK: - Lesson Filter

extension DashboardFlow {
    
    private func getLessonLanguageFilterSelection() -> UIViewController {
        
        let viewModel = LessonFilterLanguageSelectionViewModel(
            viewLessonFilterLanguagesUseCase: appDiContainer.feature.lessonFilter.domainLayer.getViewLessonFilterLanguagesUseCase(),
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getUserLessonFiltersUseCase(),
            storeUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getStoreUserLessonFiltersUseCase(),
            viewSearchBarUseCase: appDiContainer.domainLayer.getViewSearchBarUseCase(),
            searchLessonFilterLanguagesUseCase: appDiContainer.feature.lessonFilter.domainLayer.getSearchLessonFilterLanguagesUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            flowDelegate: self
        )
        
        let view = LessonFilterLanguageSelectionView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<LessonFilterLanguageSelectionView>(
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

// MARK: - Lesson Evaluation

extension DashboardFlow {
    
    private func presentLessonEvaluation(lessonId: String, pageIndexReached: Int) {
        
        let viewModel = LessonEvaluationViewModel(
            flowDelegate: self,
            lessonId: lessonId,
            pageIndexReached: pageIndexReached,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLessonEvaluationStringsUseCase: appDiContainer.feature.lessonEvaluation.domainLayer.getLessonEvaluationStringsUseCase(),
            didChangeScaleForSpiritualConversationReadinessUseCase: appDiContainer.feature.lessonEvaluation.domainLayer.getDidChangeScaleForSpiritualConversationReadinessUseCase(),
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

// MARK: - Tool Favorites

extension DashboardFlow {
    
    func getAllFavoriteTools() -> UIViewController {
        
        let viewModel = AllYourFavoriteToolsViewModel(
            flowDelegate: self,
            viewAllYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getViewAllYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            reorderFavoritedToolUseCase: appDiContainer.feature.favorites.domainLayer.getReorderFavoritedToolUseCase(),
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

// MARK: - Tutorial

extension DashboardFlow {
    
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

// MARK: - Tool Filter Selection

extension DashboardFlow {
    
    private func getToolCategoryFilterSelection() -> UIViewController {
        
        let viewModel = ToolFilterCategorySelectionViewModel(
            viewToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getViewToolFilterCategoriesUseCase(),
            searchToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSearchToolFilterCategoriesUseCase(),
            getUserToolFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFiltersUseCase(),
            storeUserToolFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getStoreUserToolFiltersUseCase(),
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
    
    private func getToolLanguageFilterSelection() -> UIViewController {
        
        let viewModel = ToolFilterLanguageSelectionViewModel(
            viewToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getViewToolFilterLanguagesUseCase(),
            searchToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSearchToolFilterLanguagesUseCase(),
            getUserToolFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFiltersUseCase(),
            storeUserToolFilterUseCase: appDiContainer.feature.toolsFilter.domainLayer.getStoreUserToolFiltersUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewSearchBarUseCase: appDiContainer.domainLayer.getViewSearchBarUseCase(),
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

// MARK: - Tool

extension DashboardFlow {
    
    private func navigateToToolInAppLanguage(toolDataModelId: String, trainingTipsEnabled: Bool, persistToolLanguageSettings: PersistToolLanguageSettingsInterface? = nil, toolOpenedFrom: ToolOpenedFrom) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        let languageIds: [String]
        
        if let appLanguageModel = languagesRepository.cache.getCachedLanguage(code: appLanguage) {
            languageIds = [appLanguageModel.id]
        }
        else {
            languageIds = Array()
        }
        
        navigateToTool(toolDataModelId: toolDataModelId, languageIds: languageIds, selectedLanguageIndex: nil, trainingTipsEnabled: trainingTipsEnabled, persistToolLanguageSettings: persistToolLanguageSettings, toolOpenedFrom: toolOpenedFrom)
    }
    
    private func navigateToToolWithUserToolLanguageSettingsApplied(toolDataModelId: String, trainingTipsEnabled: Bool, toolOpenedFrom: ToolOpenedFrom) {
        
        let userToolSettingsRepository: UserToolSettingsRepository = appDiContainer.feature.persistFavoritedToolLanguageSettings.dataLayer.getUserToolSettingsRepository()
        
        if let userToolSettings = userToolSettingsRepository.getUserToolSettings(toolId: toolDataModelId) {
            
            navigateToTool(
                toolDataModelId: toolDataModelId,
                primaryLanguageId: userToolSettings.primaryLanguageId,
                parallelLanguageId: userToolSettings.parallelLanguageId,
                selectedLanguageIndex: 0,
                trainingTipsEnabled: trainingTipsEnabled,
                persistToolLanguageSettings: appDiContainer.feature.persistFavoritedToolLanguageSettings.domainLayer.getPersistUserToolLanguageSettingsUseCase(),
                toolOpenedFrom: toolOpenedFrom
            )
            
        } else {
            
            navigateToToolInAppLanguage(
                toolDataModelId: toolDataModelId,
                trainingTipsEnabled: trainingTipsEnabled,
                persistToolLanguageSettings: appDiContainer.feature.persistFavoritedToolLanguageSettings.domainLayer.getPersistUserToolLanguageSettingsUseCase(), toolOpenedFrom: toolOpenedFrom
            )
        }
    }
    
    private func navigateToTool(toolDataModelId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, persistToolLanguageSettings: PersistToolLanguageSettingsInterface? = nil, toolOpenedFrom: ToolOpenedFrom) {
                
        var languageIds: [String] = [primaryLanguageId]
        
        if let parallelLanguageId = parallelLanguageId {
            languageIds.append(parallelLanguageId)
        }
        
        navigateToTool(toolDataModelId: toolDataModelId, languageIds: languageIds, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: trainingTipsEnabled, persistToolLanguageSettings: persistToolLanguageSettings, toolOpenedFrom: toolOpenedFrom)
    }
    
    private func navigateToTool(toolDataModelId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, persistToolLanguageSettings: PersistToolLanguageSettingsInterface? = nil, toolOpenedFrom: ToolOpenedFrom) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        var languageIds: [String] = Array()
        
        if let languageModel = languagesRepository.cache.getCachedLanguage(code: primaryLanguage) {
            languageIds.append(languageModel.id)
        }
        
        if let parallelLanguage = parallelLanguage, let languageModel = languagesRepository.cache.getCachedLanguage(code: parallelLanguage) {
            languageIds.append(languageModel.id)
        }
        
        navigateToTool(toolDataModelId: toolDataModelId, languageIds: languageIds, selectedLanguageIndex: selectedLanguageIndex, trainingTipsEnabled: trainingTipsEnabled, persistToolLanguageSettings: persistToolLanguageSettings, toolOpenedFrom: toolOpenedFrom)
    }
    
    private func navigateToLesson(lessonListItem: LessonListItemDomainModel, languageFilter: LessonFilterLanguageDomainModel?, toolOpenedFrom: ToolOpenedFrom) {
        
        if let languageFilter = languageFilter {
            navigateToTool(toolDataModelId: lessonListItem.dataModelId, languageIds: [languageFilter.languageId], selectedLanguageIndex: 0, trainingTipsEnabled: false, toolOpenedFrom: toolOpenedFrom)
        } else {
            navigateToToolInAppLanguage(toolDataModelId: lessonListItem.dataModelId, trainingTipsEnabled: false, toolOpenedFrom: toolOpenedFrom)
        }
    }
        
    private func navigateToTool(toolDataModelId: String, languageIds: [String], selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, persistToolLanguageSettings: PersistToolLanguageSettingsInterface? = nil, toolOpenedFrom: ToolOpenedFrom) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        let openToolInLanguages: [String]
        
        if languageIds.isEmpty, let englishLanguage = languagesRepository.cache.getCachedLanguage(code: LanguageCodeDomainModel.english.rawValue) {
            
            openToolInLanguages = [englishLanguage.id]
        }
        else {
            
            openToolInLanguages = languageIds
        }
        
        navigateToTool(
            appLanguage: appLanguage,
            resourceId: toolDataModelId,
            languageIds: openToolInLanguages,
            liveShareStream: nil,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: nil,
            initialPageSubIndex: nil,
            persistToolLanguageSettings: persistToolLanguageSettings,
            toolOpenedFrom: toolOpenedFrom
        )
    }
}

// MARK: - Tool Details

extension DashboardFlow {
    
    private func getToolDetails(toolId: String, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?, primaryLanguage: AppLanguageDomainModel? = nil) -> UIViewController {
        
        let viewModel = ToolDetailsViewModel(
            flowDelegate: self,
            toolId: toolId,
            primaryLanguage: primaryLanguage ?? appLanguage,
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
            accessibilityIdentifier: AccessibilityStrings.Button.toolDetailsNavBack.id
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

extension DashboardFlow {
    
    private func navigateToLearnToShareTool(toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?, toolOpenedFrom: ToolOpenedFrom) {
        
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
                trainingTipsEnabled: true,
                toolOpenedFrom: toolOpenedFrom
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

// MARK: - Confirm Remove Tool From Favorites

extension DashboardFlow {
    
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
