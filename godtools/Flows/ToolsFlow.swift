//
//  ToolsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsFlow: Flow {
    
    private var articlesFlow: ArticlesFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
             
        let openTutorialViewModel = OpenTutorialViewModel(
            flowDelegate: self,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            analytics: appDiContainer.analytics
        )
        
        let favoritedToolsViewModel = FavoritedToolsViewModel(
            flowDelegate: self,
            resourcesService: appDiContainer.resourcesService,
            favoritedResourcesService: appDiContainer.favoritedResourcesService,
            languageSettingsService: appDiContainer.languageSettingsService,
            analytics: appDiContainer.analytics
        )
        
        let allToolsViewModel = AllToolsViewModel(
            flowDelegate: self,
            resourcesService: appDiContainer.resourcesService,
            favoritedResourcesService: appDiContainer.favoritedResourcesService,
            languageSettingsService: appDiContainer.languageSettingsService,
            analytics: appDiContainer.analytics
        )
        
        let toolsMenuViewModel = ToolsMenuViewModel(
            flowDelegate: self
        )
        let view = ToolsMenuView(
            viewModel: toolsMenuViewModel,
            openTutorialViewModel: openTutorialViewModel,
            favoritedToolsViewModel: favoritedToolsViewModel,
            allToolsViewModel: allToolsViewModel
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .menuTappedFromTools:
            flowDelegate?.navigate(step: .showMenu)
        
        case .languageSettingsTappedFromTools:
            flowDelegate?.navigate(step: .showLanguageSettings)
            
        case .openTutorialTapped:
            flowDelegate?.navigate(step: .openTutorialTapped)
            
        case .toolTappedFromFavoritedTools(let resource):
            navigateToTool(resource: resource)
            
        case .aboutToolTappedFromFavoritedTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .unfavoriteToolTappedFromFavoritedTools(let resource, let removeHandler):
            
            let handler = CallbackHandler { [weak self] in
                removeHandler.handle()
                self?.navigationController.dismiss(animated: true, completion: nil)
            }
            
            // TODO: Localize this text. ~Levi
            let title: String = "Remove From Favorites?"
            let message: String = "Are you sure you want to remove \(resource.name) from your favorites?"
            let acceptedTitle: String = "YES"
            
            let viewModel = AlertMessageViewModel(
                title: title,
                message: message,
                cancelTitle: "NO",
                acceptTitle: acceptedTitle,
                acceptHandler: handler
            )
            
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .toolTappedFromAllTools(let resource):
            navigateToTool(resource: resource)
            
        case .aboutToolTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .homeTappedFromTract:
            flowDelegate?.navigate(step: .homeTappedFromTract)
            
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource)
            
        case .urlLinkTappedFromToolDetail(let url):
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        default:
            break
        }
    }
    
    private func navigateToTool(resource: ResourceModel) {
        
        let resourceType: ResourceType = ResourceType.resourceType(resource: resource)
        
        switch resourceType {
        
        case .article:
            
            let articlesFlow = ArticlesFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource
            )
            
            self.articlesFlow = articlesFlow
        
        case .tract:
            break
            /*
            // TODO: Need to fetch language from user's primary language settings. A primary language should never be null. ~Levi
            let languagesManager: LanguagesManager = appDiContainer.languagesManager
            var primaryLanguage: Language?
            if let settingsPrimaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
                primaryLanguage = settingsPrimaryLanguage
            }
            
            var resourceSupportsPrimaryLanguage: Bool = false
            for translation in resource.translations {
                if let code = translation.language?.code {
                    if code == primaryLanguage?.code {
                        resourceSupportsPrimaryLanguage = true
                        break
                    }
                }
            }
                        
            if primaryLanguage == nil || !resourceSupportsPrimaryLanguage {
                primaryLanguage = languagesManager.loadFromDisk(code: "en")
            }
            
            let parallelLanguage = languagesManager.loadParallelLanguageFromDisk()
            
            let viewModel = TractViewModel(
                flowDelegate: self,
                resource: resource,
                primaryLanguage: primaryLanguage!,
                parallelLanguage: parallelLanguage,
                tractManager: appDiContainer.tractManager,
                viewsService: appDiContainer.viewsService,
                analytics: appDiContainer.analytics,
                toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
                tractPage: 0
            )
            let view = TractView(viewModel: viewModel)

            navigationController.pushViewController(view, animated: true)
            */
        case .unknown:
            let viewModel = AlertMessageViewModel(
                title: "Internal Error",
                message: "Unknown tool type for resource.",
                cancelTitle: nil,
                acceptTitle: "OK",
                acceptHandler: nil
            )
            let view = AlertMessageView(viewModel: viewModel)
            navigationController.present(view.controller, animated: true, completion: nil)
        }
    }
    
    private func navigateToToolDetail(resource: ResourceModel) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            resourcesService: appDiContainer.resourcesService,
            favoritedResourcesService: appDiContainer.favoritedResourcesService,
            languageSettingsService: appDiContainer.languageSettingsService,
            localization: appDiContainer.localizationServices,
            preferredLanguageTranslation: appDiContainer.preferredLanguageTranslation,
            analytics: appDiContainer.analytics,
            exitLinkAnalytics: appDiContainer.exitLinkAnalytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
