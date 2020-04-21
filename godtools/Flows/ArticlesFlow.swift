//
//  ArticlesFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticlesFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: DownloadedResource, language: Language) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: resource,
            language: language,
            getResourceLatestTranslationServices: appDiContainer.getResourceLatestTranslationServices,
            analytics: appDiContainer.analytics
        )
        let view = ArticleCategoriesView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)        
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .articleTappedFromArticles(let category, let resource):
            
            // TODO: Add ViewModel. ~Levi
            let vc = ArticleCategoryViewController.create()
            vc.articleManager = appDiContainer.articleManager
            vc.category = category
            vc.articlesPath = appDiContainer.articleManager.articlesPath
            vc.resource = resource
            navigationController.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
}
