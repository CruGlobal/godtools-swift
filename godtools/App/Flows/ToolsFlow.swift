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
                
        configureNavigationBar()
        
        let viewModel = ToolsMenuViewModel(
            flowDelegate: self,
            initialDataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            analytics: appDiContainer.analytics,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache
        )
        
        let view = ToolsMenuView(
            viewModel: viewModel,
            startingToolbarItem: startingToolbarItem ?? ToolsFlow.defaultStartingToolsMenu
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    private func configureNavigationBar() {
                
        let fontService: FontService = appDiContainer.getFontService()
        let font: UIFont = fontService.getFont(size: 17, weight: .semibold)
        
        navigationController.setNavigationBarHidden(false, animated: true)
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
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .openTutorialTapped:
            flowDelegate?.navigate(step: .openTutorialTapped)
           
        case .menuTappedFromTools:
            flowDelegate?.navigate(step: .showMenu)
        
        case .languageSettingsTappedFromTools:
            flowDelegate?.navigate(step: .showLanguageSettings)
            
        case .lessonTappedFromLessonsList(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
        case .toolTappedFromFavoritedTools(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
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
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
                        
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
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
                
                navigateToTool(resource: resource, trainingTipsEnabled: true)
            }
            
        case .continueTappedFromLearnToShareTool(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .closeTappedFromLearnToShareTool(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .urlLinkTappedFromToolDetail(let url, let exitLink):
            navigateToURL(url: url, exitLink: exitLink)
            
        case .articleFlowCompleted(let state):
            
            guard articleFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar()
            
            articleFlow = nil
            
        case .lessonFlowCompleted(let state):
            
            guard lessonFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar()
            
            lessonFlow = nil
            
        case .tractFlowCompleted(let state):
            
            guard tractFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar()
            
            tractFlow = nil
            
        default:
            break
        }
    }
    
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
}
