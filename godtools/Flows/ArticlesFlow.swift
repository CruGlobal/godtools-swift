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
            
        case .articleCategoryTappedFromArticleCategories(let category, let resource, let articleManifest):
            
            let viewModel = ArticlesViewModel(
                flowDelegate: self,
                resource: resource,
                category: category,
                articleManifest: articleManifest,
                articleAemImportService: appDiContainer.articleAemImportService,
                analytics: appDiContainer.analytics
            )
            let view = ArticlesView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
                        
        case .articleTappedFromArticles(let articleAemImportData, let resource):
            
            let viewModel = ArticleWebViewModel(
                articleAemImportData: articleAemImportData,
                resource: resource,
                analytics: appDiContainer.analytics
            )
            
            let view = ArticleWebView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        default:
            break
        }
    }
}
