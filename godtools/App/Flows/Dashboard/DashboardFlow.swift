//
//  DashboardFlow.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import Combine

final class DashboardFlow: GTFlow {
        
    static let startingTab: DashboardTabTypeDomainModel = .favorites
    
    private let dashboardTabObserver: CurrentValueSubject<DashboardTabTypeDomainModel, Never>
        
    private(set) var menuFlow: MenuFlow?
    
    let rootController: AppRootController
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    init(appDiContainer: AppDiContainer, rootController: AppRootController) {
        
        self.rootController = rootController
        
        dashboardTabObserver = CurrentValueSubject(Self.startingTab)
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getDashboardView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                startingTab: Self.startingTab,
                dashboardTabObserver: dashboardTabObserver
            ),
            stepEmitter: stepEmitter
        )
                
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
    }
    
    private var dashboardView: AppHostingController<DashboardView>? {
        for viewController in navigationController.viewControllers {
            if let dashboardView = viewController as? AppHostingController<DashboardView> {
                return dashboardView
            }
        }
        return nil
    }
    
    func setMenuFlow(menuFlow: MenuFlow?) {
        self.menuFlow = menuFlow
    }
    
    override func navigate(step: FlowStep) {
             
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
                        
        case .menuTappedFromTools:
            navigateToMenu(appLanguage: appLanguage, animated: true)
            
        case .doneTappedFromMenu:
            closeMenu(animated: true)
            
        case .lessonTappedFromLessonsList(let lessonListItem, let languageFilter):
            navigateToLesson(lessonListItem: lessonListItem, languageFilter: languageFilter, toolOpenedFrom: .dashboardLessons)
            
        case .lessonLanguageFilterTappedFromLessons:
            navigationController.pushViewController(getLessonLanguageFilterSelection(), animated: true)
            
        case .backTappedFromLessonLanguageFilter:
            navigationController.popViewController(animated: true)

        case .changeLocalizationSettingsTappedFromLessons:
            pushFlow(
                flow: LocalizationSettingsFlow(
                    appDiContainer: appDiContainer,
                    shouldStoreCountryWhenSelected: true
                )
            )
            
        case .localizationSettingsFlowCompleted( _):
            popFlow()

        case .languageTappedFromLessonLanguageFilter:
            navigationController.popViewController(animated: true)
            
        case .featuredLessonTappedFromFavorites(let featuredLesson):
            navigateToToolInAppLanguage(
                toolDataModelId: featuredLesson.dataModelId,
                trainingTipsEnabled: false,
                toolOpenedFrom: .dashboardFavoritesFeaturedLesson,
                persistToolLanguageSettings: nil
            )
            
        case .viewAllFavoriteToolsTappedFromFavorites:
            navigationController.pushViewController(getAllFavoriteTools(), animated: true)
            
        case .toolDetailsTappedFromFavorites(let tool):
            navigateToToolDetails(toolId: tool.dataModelId)
        
        case .openToolTappedFromFavorites(let tool):
            navigateToToolWithToolLanguageSettingsAppliedForFavoritedTool(
                toolDataModelId: tool.dataModelId,
                trainingTipsEnabled: false,
                toolOpenedFrom: .dashboardFavoritesFavoritedTool
            )
            
        case .toolTappedFromFavorites(let tool):
            navigateToToolWithToolLanguageSettingsAppliedForFavoritedTool(
                toolDataModelId: tool.dataModelId,
                trainingTipsEnabled: false,
                toolOpenedFrom: .dashboardFavoritesFavoritedTool
            )
            
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
            navigateToToolDetails(toolId: tool.dataModelId)
        
        case .openTutorialTappedFromTools:
            presentFlow(
                flow: TutorialFlow(appDiContainer: appDiContainer)
            )
            
        case .tutorialFlowCompleted( _):
            dismissFlow()

        case .openToolTappedFromAllYourFavoriteTools(let tool):
            navigateToToolWithToolLanguageSettingsAppliedForFavoritedTool(
                toolDataModelId: tool.dataModelId,
                trainingTipsEnabled: false,
                toolOpenedFrom: .dashboardFavoritesFavoritedTool
            )
            
        case .toolTappedFromAllYourFavoritedTools(let tool):
            navigateToToolWithToolLanguageSettingsAppliedForFavoritedTool(
                toolDataModelId: tool.dataModelId,
                trainingTipsEnabled: false,
                toolOpenedFrom: .dashboardFavoritesFavoritedTool
            )
            
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
            
            let toolFilterLanguageDataModel: LanguageDataModel?
            
            if let languageId = toolFilterLanguage?.id {
                toolFilterLanguageDataModel = appDiContainer.core.dataLayer.getLanguagesRepository().getLanguageById(id: languageId)
            }
            else {
                toolFilterLanguageDataModel = nil
            }
            
            navigateToToolDetails(
                toolId: spotlightTool.dataModelId,
                parallelLanguage: toolFilterLanguageDataModel?.localeId,
                selectedLanguageIndex: 1
            )
                        
        case .toolTappedFromTools(let tool, let toolFilterLanguage):
            
            let toolFilterLanguageDataModel: LanguageDataModel?
            
            if let languageId = toolFilterLanguage?.id {
                toolFilterLanguageDataModel = appDiContainer.core.dataLayer.getLanguagesRepository().getLanguageById(id: languageId)
            }
            else {
                toolFilterLanguageDataModel = nil
            }
            
            let resourcesRepository: ResourcesRepository = appDiContainer.core.dataLayer.getResourcesRepository()
            
            let primaryLanguage: AppLanguageDomainModel?
            let parallelLanguage: AppLanguageDomainModel?
            
            if let toolResource = resourcesRepository.getResourceById(id: tool.dataModelId),
               toolResource.resourceTypeEnum == .article {
                
                parallelLanguage = nil
                
                if let toolFilterLanguageDataModel = toolFilterLanguageDataModel,
                   toolResource.supportsLanguage(languageId: toolFilterLanguageDataModel.id) {
                    
                    primaryLanguage = toolFilterLanguageDataModel.localeId
                }
                else {
                    
                    primaryLanguage = appLanguage
                }
            }
            else {
                
                primaryLanguage = nil
                parallelLanguage = toolFilterLanguageDataModel?.localeId
            }
            
            navigateToToolDetails(
                toolId: tool.dataModelId,
                primaryLanguage: primaryLanguage,
                parallelLanguage: parallelLanguage,
                selectedLanguageIndex: 1
            )
            
        case .changeLocalizationSettingsTappedFromTools:
            pushFlow(
                flow: LocalizationSettingsFlow(
                    appDiContainer: appDiContainer,
                    shouldStoreCountryWhenSelected: true
                )
            )
            
        case .openToolTappedFromToolDetails(let tool):
            
            if dashboardTabObserver.value == .favorites {
                
                navigateToToolWithToolLanguageSettingsAppliedForFavoritedTool(
                    toolDataModelId: tool.toolId,
                    trainingTipsEnabled: false,
                    toolOpenedFrom: .dashboardFavoritesFavoritedTool
                )
            }
            else {
                
                navigateToTool(
                    toolDataModelId: tool.toolId,
                    primaryLanguage: tool.primaryLanguage,
                    parallelLanguage: tool.parallelLanguage,
                    selectedLanguageIndex: tool.selectedLanguageIndex,
                    trainingTipsEnabled: false,
                    toolOpenedFrom: .dashboardTools,
                    persistToolLanguageSettings: nil
                )
            }
            
        case .backTappedFromToolDetails:
            navigationController.popViewController(animated: true)
            
        case .urlLinkTappedFromToolDetails(let urlLinkTapped):
            navigateToURL(linkTapped: urlLinkTapped, appLanguage: appLanguage)
            
        case .learnToShareToolTappedFromToolDetails(let tool):
            navigateToLearnToShareToolElseTool(
                tool: tool,
                toolOpenedFrom: .learnToShare
            )
            
        case .startTrainingTappedFromLearnToShareTool(let tool):
            dismissFlow(completion: { [weak self] in
                
                self?.navigateToTool(
                    toolDataModelId: tool.toolId,
                    primaryLanguage: tool.primaryLanguage,
                    parallelLanguage: tool.parallelLanguage,
                    selectedLanguageIndex: tool.selectedLanguageIndex,
                    trainingTipsEnabled: true,
                    toolOpenedFrom: .learnToShare,
                    persistToolLanguageSettings: nil
                )
            })
            
        case .closeTappedFromLearnToShareTool(let tool):
            dismissFlow(completion: { [weak self] in
                
                self?.navigateToTool(
                    toolDataModelId: tool.toolId,
                    primaryLanguage: tool.primaryLanguage,
                    parallelLanguage: tool.parallelLanguage,
                    selectedLanguageIndex: tool.selectedLanguageIndex,
                    trainingTipsEnabled: true,
                    toolOpenedFrom: .learnToShare,
                    persistToolLanguageSettings: nil
                )
            })
                        
        case .closeTappedFromLessonEvaluation:
            dismissLessonEvaluation()
            
        case .sendFeedbackTappedFromLessonEvaluation:
            dismissLessonEvaluation()
        
        case .backgroundTappedFromLessonEvaluation:
            dismissLessonEvaluation()
            
        case .toolNavigationFlowCompleted(let state):
            
            switch state {
                
            case .downloadFailed:
                popFlow()
                
            case .userClosedDownloadTool:
                popFlow()
                
            case .articleCategoriesFlowCompleted( _):
                popFlow(
                    popToViewController: dashboardView
                )
            
            case .tractFlowCompleted(let tractCompletedState):
                
                popFlow(
                    popToViewController: dashboardView
                )
                
                switch tractCompletedState {
                
                case .userClosedTract:
                    break
                
                case .userClosedTractToLessonsList:
                    dashboardView?.rootView.navigateToTab(tab: .lessons)
                }
                
            case .lessonFlowCompleted(let state):
                
                popFlow(
                    popToViewController: dashboardView
                )
                
                switch state {
                
                case .userClosedLesson(let lessonId, let lessonLanguage, let highestPageNumberViewed, let toolOpenedFrom):
                    
                    if toolOpenedFrom == .dashboardLessons {
                        dashboardView?.rootView.navigateToTab(tab: .lessons)
                    }
                                       
                    let lessonReachedEvaluation: Bool = highestPageNumberViewed > 2
                    let lessonAlreadyEvaluated: Bool = appDiContainer.feature.lessonEvaluation.domainLayer.getLessonEvaluatedUseCase()
                        .execute(lessonId: lessonId)
                    
                    if lessonReachedEvaluation && !lessonAlreadyEvaluated {
                        
                        presentLessonEvaluation(
                            lessonId: lessonId,
                            lessonLanguage: lessonLanguage,
                            pageIndexReached: highestPageNumberViewed
                        )
                    }
                }
                
            case .chooseYourOwnAdventureFlowCompleted( _):
                popFlow(
                    popToViewController: dashboardView
                )
            }
            
        default:
            break
        }
    }
}

// MARK: - Dashboard

extension DashboardFlow {
    
    private static func getDashboardView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        startingTab: DashboardTabTypeDomainModel?,
        dashboardTabObserver: CurrentValueSubject<DashboardTabTypeDomainModel, Never>
    ) -> UIViewController {
                
        let viewModel = DashboardViewModel(
            stepEmitter: stepEmitter,
            startingTab: startingTab ?? Self.startingTab,
            dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter
            ),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDashboardStringsUseCase: appDiContainer.feature.dashboard.domainLayer.getDashboardStringsUseCase(),
            dashboardTabObserver: dashboardTabObserver
        )
                
        let view = DashboardView(viewModel: viewModel)
            
        let hostingController = AppHostingController<DashboardView>(
            rootView: view,
            navigationBar: nil
        )
    
        return hostingController
    }
    
    func configureNavBarForDashboard() {
        
        GodToolsSceneDelegate.setWindowBackgroundColorForStatusBarColor(color: AppFlow.defaultNavBarColor)
                
        appNavigationController?.resetNavigationBarAppearance()
        
        appNavigationController?.setSemanticContentAttribute(semanticContentAttribute: ApplicationLayout.shared.currentDirection.semanticContentAttribute)
        
        appNavigationController?.setLayoutDirectionPublisherToApplicationLayout()
    }
    
    func navigateToDashboard(
        startingTab: DashboardTabTypeDomainModel? = nil,
        animatePopToDashboard: Bool = false,
        animateDismissingPresentedView: Bool = false,
        didCompleteDismissingPresentedView: (() -> Void)? = nil
    ) {
        
        let startingTab: DashboardTabTypeDomainModel = startingTab ?? Self.startingTab
        
        if let dashboard = dashboardView {
            
            dashboard.rootView.navigateToTab(tab: startingTab)
        }
        else {
            
            let dashboard = Self.getDashboardView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                startingTab: startingTab,
                dashboardTabObserver: dashboardTabObserver
            )
            
            navigationController.setViewControllers([dashboard], animated: false)
        }
                
        closeMenu(animated: false)
        
        removeAllFlows()
                
        navigationController.popToRootViewController(animated: animatePopToDashboard)
                
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
            stepEmitter: stepEmitter,
            getLessonFilterLanguagesStringsUseCase: appDiContainer.feature.lessonFilter.domainLayer.getLessonFilterLanguagesStringsUseCase(),
            getLessonFilterLanguagesUseCase: appDiContainer.feature.lessonFilter.domainLayer.getLessonFilterLanguagesUseCase(),
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getUserLessonFiltersUseCase(),
            storeUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getStoreUserLessonFiltersUseCase(),
            getSearchBarStringsUseCase: appDiContainer.core.domainLayer.getSearchBarStringsUseCase(),
            searchLessonFilterLanguagesUseCase: appDiContainer.feature.lessonFilter.domainLayer.getSearchLessonFilterLanguagesUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
        )
        
        let view = LessonFilterLanguageSelectionView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
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
    
    private func presentLessonEvaluation(lessonId: String, lessonLanguage: AppLanguageDomainModel, pageIndexReached: Int) {
        
        presentView(
            view: getLessonEvaluationView(
                lessonId: lessonId,
                lessonLanguage: lessonLanguage,
                pageIndexReached: pageIndexReached
            ),
            animated: true
        )
    }
    
    private func dismissLessonEvaluation() {
        
        dismissView(animated: true)
    }
    
    private func getLessonEvaluationView(lessonId: String, lessonLanguage: AppLanguageDomainModel, pageIndexReached: Int) -> UIViewController {
        
        let viewModel = LessonEvaluationViewModel(
            stepEmitter: stepEmitter,
            lessonId: lessonId,
            lessonLanguage: lessonLanguage,
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
        
        return overlayNavigationController
    }
}

// MARK: - Tool Favorites

extension DashboardFlow {
    
    func getAllFavoriteTools() -> UIViewController {
        
        let viewModel = AllYourFavoriteToolsViewModel(
            stepEmitter: stepEmitter,
            getAllYourFavoritedToolsStringsUseCase: appDiContainer.feature.favorites.domainLayer.getAllYourFavoritedToolsStringsUseCase(),
            getYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            reorderFavoritedToolUseCase: appDiContainer.feature.favorites.domainLayer.getReorderFavoritedToolUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = AllYourFavoriteToolsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
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

// MARK: - Tool Filter Selection

extension DashboardFlow {
    
    private func getToolCategoryFilterSelection() -> UIViewController {
        
        let viewModel = ToolFilterCategorySelectionViewModel(
            stepEmitter: stepEmitter,
            getToolFilterCategoriesStringsUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterCategoriesStringsUseCase(),
            getToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterCategoriesUseCase(),
            searchToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSearchToolFilterCategoriesUseCase(),
            getUserToolFilterCategoryUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterCategoryUseCase(),
            getUserToolFilterLanguageUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterLanguageUseCase(),
            selectedToolFilterCategoryUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSelectedToolFilterCategoryUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getSearchBarStringsUseCase: appDiContainer.core.domainLayer.getSearchBarStringsUseCase()
        )
        
        let view = ToolFilterCategorySelectionView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backButtonTapped)
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
            stepEmitter: stepEmitter,
            getToolFilterLanguagesStringsUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterLanguagesStringsUseCase(),
            getToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterLanguagesUseCase(),
            searchToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSearchToolFilterLanguagesUseCase(),
            getUserToolFilterCategoryUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterCategoryUseCase(),
            getUserToolFilterLanguageUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterLanguageUseCase(),
            selectedToolFilterLanguageUseCase: appDiContainer.feature.toolsFilter.domainLayer.getSelectedToolFilterLanguageUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getSearchBarStringsUseCase: appDiContainer.core.domainLayer.getSearchBarStringsUseCase()
        )
        
        let view = ToolFilterLanguageSelectionView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backButtonTapped)
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
    
    private func navigateToToolInAppLanguage(toolDataModelId: String, trainingTipsEnabled: Bool, toolOpenedFrom: ToolOpenedFrom, persistToolLanguageSettings: PersistToolLanguageSettingsInterface?) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.core.dataLayer.getLanguagesRepository()
        
        let languageIds: [String]
        
        if let appLanguageModel = languagesRepository.getLanguageByCode(code: appLanguage) {
            languageIds = [appLanguageModel.id]
        }
        else {
            languageIds = Array()
        }
        
        navigateToTool(
            toolDataModelId: toolDataModelId,
            languageIds: languageIds,
            selectedLanguageIndex: nil,
            trainingTipsEnabled: trainingTipsEnabled,
            toolOpenedFrom: toolOpenedFrom,
            persistToolLanguageSettings: persistToolLanguageSettings
        )
    }
    
    private func navigateToToolWithToolLanguageSettingsAppliedForFavoritedTool(toolDataModelId: String, trainingTipsEnabled: Bool, toolOpenedFrom: ToolOpenedFrom) {
        
        let userFavoritedToolSettingsRepository: UserToolSettingsRepository = appDiContainer.feature.persistToolLanguageSettingsForFavoritedTool.dataLayer.getUserToolSettingsRepository()
        
        if let userToolSettings = userFavoritedToolSettingsRepository.getUserToolSettings(toolId: toolDataModelId) {
            
            navigateToTool(
                toolDataModelId: toolDataModelId,
                primaryLanguageId: userToolSettings.primaryLanguageId,
                parallelLanguageId: userToolSettings.parallelLanguageId,
                selectedLanguageIndex: 0,
                trainingTipsEnabled: trainingTipsEnabled,
                toolOpenedFrom: toolOpenedFrom,
                persistToolLanguageSettings: appDiContainer.feature.persistToolLanguageSettingsForFavoritedTool.domainLayer.getPersistToolLanguageSettingsForFavoritedToolUseCase()
            )
            
        } else {
            
            navigateToToolInAppLanguage(
                toolDataModelId: toolDataModelId,
                trainingTipsEnabled: trainingTipsEnabled,
                toolOpenedFrom: toolOpenedFrom,
                persistToolLanguageSettings: appDiContainer.feature.persistToolLanguageSettingsForFavoritedTool.domainLayer.getPersistToolLanguageSettingsForFavoritedToolUseCase()
            )
        }
    }
    
    private func navigateToTool(
        toolDataModelId: String,
        primaryLanguageId: String,
        parallelLanguageId: String?,
        selectedLanguageIndex: Int?,
        trainingTipsEnabled: Bool,
        toolOpenedFrom: ToolOpenedFrom,
        persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    ) {
                
        var languageIds: [String] = [primaryLanguageId]
        
        if let parallelLanguageId = parallelLanguageId {
            languageIds.append(parallelLanguageId)
        }
        
        navigateToTool(
            toolDataModelId: toolDataModelId,
            languageIds: languageIds,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            toolOpenedFrom: toolOpenedFrom,
            persistToolLanguageSettings: persistToolLanguageSettings
        )
    }
    
    private func navigateToTool(
        toolDataModelId: String,
        primaryLanguage: AppLanguageDomainModel,
        parallelLanguage: AppLanguageDomainModel?,
        selectedLanguageIndex: Int?,
        trainingTipsEnabled: Bool,
        toolOpenedFrom: ToolOpenedFrom,
        persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    ) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.core.dataLayer.getLanguagesRepository()
        
        var languageIds: [String] = Array()
        
        if let languageModel = languagesRepository.getLanguageByCode(code: primaryLanguage) {
            languageIds.append(languageModel.id)
        }
        
        if let parallelLanguage = parallelLanguage, let languageModel = languagesRepository.getLanguageByCode(code: parallelLanguage) {
            languageIds.append(languageModel.id)
        }
        
        navigateToTool(
            toolDataModelId: toolDataModelId,
            languageIds: languageIds,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            toolOpenedFrom: toolOpenedFrom,
            persistToolLanguageSettings: persistToolLanguageSettings
        )
    }
    
    private func navigateToLesson(
        lessonListItem: LessonListItemDomainModel,
        languageFilter: LessonFilterLanguageDomainModel?,
        toolOpenedFrom: ToolOpenedFrom
    ) {
        
        if let languageFilter = languageFilter {
            
            navigateToTool(
                toolDataModelId: lessonListItem.dataModelId,
                languageIds: [languageFilter.languageId],
                selectedLanguageIndex: 0,
                trainingTipsEnabled: false,
                toolOpenedFrom: toolOpenedFrom,
                persistToolLanguageSettings: nil
            )
        }
        else {
            
            navigateToToolInAppLanguage(
                toolDataModelId: lessonListItem.dataModelId,
                trainingTipsEnabled: false,
                toolOpenedFrom: toolOpenedFrom,
                persistToolLanguageSettings: nil
            )
        }
    }
        
    private func navigateToTool(
        toolDataModelId: String,
        languageIds: [String],
        selectedLanguageIndex: Int?,
        trainingTipsEnabled: Bool,
        toolOpenedFrom: ToolOpenedFrom,
        persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    ) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.core.dataLayer.getLanguagesRepository()
        
        let openToolInLanguages: [String]
        
        if languageIds.isEmpty, let englishLanguage = languagesRepository.getLanguageByCode(code: LanguageCodeDomainModel.english.rawValue) {
            
            openToolInLanguages = [englishLanguage.id]
        }
        else {
            
            openToolInLanguages = languageIds
        }
        
        pushFlow(
            flow: ToolNavigationFlow(
                appDiContainer: appDiContainer,
                appLanguage: appLanguage,
                resourceId: toolDataModelId,
                languageIds: openToolInLanguages,
                liveShareStream: nil,
                selectedLanguageIndex: selectedLanguageIndex,
                trainingTipsEnabled: trainingTipsEnabled,
                initialPage: nil,
                initialPageSubIndex: nil,
                toolOpenedFrom: toolOpenedFrom,
                persistToolLanguageSettings: persistToolLanguageSettings
            )
        )
    }
    
    func navigateToToolFromDeepLink(appLanguage: AppLanguageDomainModel, toolDeepLink: ToolDeepLink) {
        
        pushFlow(
            flow: ToolNavigationFlow(
                appDiContainer: appDiContainer,
                appLanguage: appLanguage,
                toolDeepLink: toolDeepLink
            )
        )
    }
}

// MARK: - Tool Details

extension DashboardFlow {
    
    func navigateToToolDetails(
        toolId: String,
        primaryLanguage: AppLanguageDomainModel? = nil,
        parallelLanguage: AppLanguageDomainModel? = nil,
        selectedLanguageIndex: Int? = nil,
        animated: Bool = true
    ) {
        
        let tool = ToolDetailsTool(
            appLanguage: appLanguage,
            toolId: toolId,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage,
            selectedLanguageIndex: selectedLanguageIndex
        )
        
        let toolDetails = getToolDetails(tool: tool)
        
        navigationController.pushViewController(toolDetails, animated: animated)
    }
    
    private func getToolDetails(tool: ToolDetailsTool) -> UIViewController {
        
        let viewModel = ToolDetailsViewModel(
            stepEmitter: stepEmitter,
            tool: tool,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolDetailsStringsUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsStringsUseCase(),
            getToolDetailsUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsUseCase(),
            getToolDetailsMediaUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsMediaUseCase(),
            getToolDetailsLearnToShareToolIsAvailableUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsLearnToShareToolIsAvailableUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleToolFavoritedUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ToolDetailsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: AccessibilityStrings.Button.back.id
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
    
    private func navigateToLearnToShareToolElseTool(
        tool: ToolDetailsTool,
        toolOpenedFrom: ToolOpenedFrom
    ) {
        
        Task {
            
            let learnToShareTutorialIsAvailable: Bool = await appDiContainer
                .feature
                .learnToShareTool
                .domainLayer
                .getLearnToShareToolTutorialIsAvailableUseCase()
                .execute(
                    appLanguage: tool.primaryLanguage,
                    toolId: tool.toolId
                )
                    
            if learnToShareTutorialIsAvailable {
                
                presentFlow(
                    flow: LearnToShareToolFlow(
                        appDiContainer: appDiContainer,
                        tool: tool
                    )
                )
                
                await appDiContainer
                    .feature
                    .learnToShareTool
                    .domainLayer
                    .getViewedLearnToShareToolTutorialUseCase()
                    .execute(
                        appLanguage: tool.primaryLanguage,
                        toolId: tool.toolId
                    )
            }
            else {
                
                navigateToTool(
                    toolDataModelId: tool.toolId,
                    primaryLanguage: tool.primaryLanguage,
                    parallelLanguage: tool.parallelLanguage,
                    selectedLanguageIndex: tool.selectedLanguageIndex,
                    trainingTipsEnabled: true,
                    toolOpenedFrom: toolOpenedFrom,
                    persistToolLanguageSettings: nil
                )
            }
        }
    }
}

// MARK: - Confirm Remove Tool From Favorites

extension DashboardFlow {
    
    private func getConfirmRemoveToolFromFavoritesAlertView(
        toolId: String,
        strings: ConfirmRemoveToolFromFavoritesStringsDomainModel,
        didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?
    ) -> UIViewController {

        let viewModel = ConfirmRemoveToolFromFavoritesAlertViewModel(
            toolId: toolId,
            appLanguage: appLanguage,
            strings: strings,
            removeFavoritedToolUseCase: appDiContainer.feature.favorites.domainLayer.getRemoveFavoritedToolUseCase(),
            didConfirmToolRemovalSubject: didConfirmToolRemovalSubject
        )
        
        let view = ConfirmRemoveToolFromFavoritesAlertView(viewModel: viewModel)
        
        return view.controller
    }
    
    private func presentConfirmRemoveToolFromFavoritesAlertView(
        toolId: String,
        didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?,
        animated: Bool
    ) {

        let strings = appDiContainer.feature.favorites.domainLayer.getConfirmRemoveToolFromFavoritesStringsUseCase()
            .execute(toolId: toolId, appLanguage: appLanguage)

        let view = getConfirmRemoveToolFromFavoritesAlertView(
            toolId: toolId,
            strings: strings,
            didConfirmToolRemovalSubject: didConfirmToolRemovalSubject
        )

        presentView(view: view, animated: animated)
    }
}
