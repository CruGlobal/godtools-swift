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
            resourcesDownloaderAndCache: appDiContainer.resourcesDownloaderAndCache,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsCache: appDiContainer.languageSettingsCache,
            analytics: appDiContainer.analytics
        )
        
        let allToolsViewModel = AllToolsViewModel(
            flowDelegate: self,
            resourcesDownloaderAndCache: appDiContainer.resourcesDownloaderAndCache,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsCache: appDiContainer.languageSettingsCache,
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
            
        case .toolDetailsTappedFromFavoritedTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .toolTappedFromAllTools(let resource):
            navigateToTool(resource: resource)
            
        case .toolDetailsTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource)
            
        case .homeTappedFromTract:
            flowDelegate?.navigate(step: .homeTappedFromTract)
            
        default:
            break
        }
    }
    
    private func navigateToTool(resource: DownloadedResource) {
        
        switch resource.toolTypeEnum {
        
        case .article:
            
            // TODO: Need to fetch language from user's primary language settings. A primary language should never be null. ~Levi
            let languagesManager: LanguagesManager = appDiContainer.languagesManager
            var language: Language?
            if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
                language = primaryLanguage
            }
            else {
                language = languagesManager.loadFromDisk(code: "en")
            }
            
            let articlesFlow = ArticlesFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                resource: resource,
                language: language!
            )
            
            self.articlesFlow = articlesFlow
        
        case .tract:
            
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
        
        case .unknown:
            let viewModel = AlertMessageViewModel(title: "Internal Error", message: "Unknown tool type for resource.", acceptActionTitle: "OK", handler: nil)
            let view = AlertMessageView(viewModel: viewModel)
            navigationController.present(view.controller, animated: true, completion: nil)
        }
    }
    
    private func navigateToToolDetail(resource: DownloadedResource) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            analytics: appDiContainer.analytics,
            exitLinkAnalytics: appDiContainer.exitLinkAnalytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
