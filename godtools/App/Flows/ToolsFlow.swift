//
//  ToolsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsFlow: ToolNavigationFlow, Flow {
    
    private static let defaultStartingToolsMenu: ToolsMenuToolbarView.ToolbarItemView = .favoritedTools
        
    private let dataDownloader: InitialDataDownloader
    
    private var learnToShareToolFlow: LearnToShareToolFlow?
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView?) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.dataDownloader = appDiContainer.initialDataDownloader
                
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: false)
        
        let viewModel = ToolsMenuViewModel(
            flowDelegate: self,
            initialDataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            analytics: appDiContainer.analytics,
            getTutorialIsAvailableUseCase: appDiContainer.getTutorialIsAvailableUseCase(),
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache
        )
        
        let view = ToolsMenuView(
            viewModel: viewModel,
            startingToolbarItem: startingToolbarItem ?? ToolsFlow.defaultStartingToolsMenu
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        
        AppDelegate.setWindowBackgroundColorForStatusBarColor(color: ColorPalette.primaryNavBar.color)
        
        navigationController.setNavigationBarHidden(false, animated: shouldAnimateNavigationBarHiddenState)
        
        let fontService: FontService = appDiContainer.getFontService()
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: ColorPalette.primaryNavBar.color,
            controlColor: .white,
            titleFont: fontService.getFont(size: 17, weight: .semibold),
            titleColor: .white,
            isTranslucent: false
        )
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .showSetupParallelLanguage:
            presentSetupParallelLanguage()
        
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
        
        case .openTutorialTapped:
            flowDelegate?.navigate(step: .openTutorialTapped)
            
        case .menuTappedFromTools:
            flowDelegate?.navigate(step: .showMenu)
        
        case .languageSettingsTappedFromTools:
            flowDelegate?.navigate(step: .showLanguageSettings)
            
        case .lessonTappedFromLessonsList(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .toolTappedFromFavoritedTools(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromFavoritedTools(let resource):
            navigateToToolDetail(resource: resource)
            
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
            
        case .toolTappedFromAllTools(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
                        
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: false)
            
        case .learnToShareToolTappedFromToolDetails(let resource):
            
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
            
        case .continueTappedFromLearnToShareTool(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .closeTappedFromLearnToShareTool(let resource):
            navigateToTool(resourceId: resource.id, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .urlLinkTappedFromToolDetail(let url, let exitLink):
            navigateToURL(url: url, exitLink: exitLink)
            
        case .articleFlowCompleted(let state):
            
            guard articleFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            navigate(step: .showSetupParallelLanguage)
            
            articleFlow = nil
            
        case .lessonFlowCompleted(let state):
            
            guard lessonFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
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
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            tractFlow = nil
            
        default:
            break
        }
    }
}

// MARK: - Lesson Evaluation

extension ToolsFlow {
    
    private func dismissLearnToShareToolFlow() {
        
        if learnToShareToolFlow != nil {
            navigationController.dismiss(animated: true, completion: nil)
        }
        
        self.learnToShareToolFlow = nil
    }
    
    private func navigateToToolDetail(resource: ResourceModel) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            dataDownloader: appDiContainer.initialDataDownloader,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            translationDownloader: appDiContainer.translationDownloader,
            analytics: appDiContainer.analytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
    
    private func presentLessonEvaluation(lesson: ResourceModel, pageIndexReached: Int) {
        
        let viewModel = LessonEvaluationViewModel(
            flowDelegate: self,
            lesson: lesson,
            pageIndexReached: pageIndexReached,
            lessonEvaluationRepository: appDiContainer.getLessonsEvaluationRepository(),
            lessonFeedbackAnalytics: appDiContainer.getLessonFeedbackAnalytics(),
            languageSettings: appDiContainer.languageSettingsService,
            localization: appDiContainer.localizationServices
        )
        let view = LessonEvaluationView(viewModel: viewModel)
        
        let modalView = TransparentModalView(flowDelegate: self, modalView: view, closeModalFlowStep: .backgroundTappedFromLessonEvaluation)
        
        navigationController.present(modalView, animated: true, completion: nil)
    }
    
    private func presentSetupParallelLanguage() {
                
        if appDiContainer.getSetupParallelLanguageAvailability().setupParallelLanguageIsAvailable {
            
            let viewModel = SetupParallelLanguageViewModel(
                flowDelegate: self,
                localizationServices: appDiContainer.localizationServices,
                languageSettingsService: appDiContainer.languageSettingsService,
                setupParallelLanguageAvailability: appDiContainer.getSetupParallelLanguageAvailability()
            )
            let view = SetupParallelLanguageView(viewModel: viewModel)
            
            let modalView = TransparentModalView(flowDelegate: self, modalView: view, closeModalFlowStep: .backgroundTappedFromSetupParallelLanguage)
            
            navigationController.present(modalView, animated: true, completion: nil)
        }
    }
    
    private func presentParallelLanguage() {
        
        let viewModel = ParallelLanguageListViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices
        )
        let view = ParallelLanguageListView(viewModel: viewModel)
        
        let modalView = TransparentModalView(flowDelegate: self, modalView: view,  closeModalFlowStep: .backgroundTappedFromParallelLanguageList)
        
        navigationController.presentedViewController?.present(modalView, animated: true, completion: nil)
    }
    
    private func dismissLessonEvaluation() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func dismissSetupParallelLanguage() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func dismissParallelLanguage() {
        navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
