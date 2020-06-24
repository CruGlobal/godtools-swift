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
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: ResourceModel, translationManifest: TranslationManifest) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: resource,
            translationManifest: translationManifest,
            articleAemImportDownloader: appDiContainer.articleAemImportDownloader,
            translationsFileCache: appDiContainer.translationsFileCache,
            analytics: appDiContainer.analytics
        )
        
        let view = ArticleCategoriesView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .articleCategoryTappedFromArticleCategories(let resource, let translationManifest, let category, let articleManifest):
            
            let viewModel = ArticlesViewModel(
                flowDelegate: self,
                resource: resource,
                translationManifest: translationManifest,
                category: category,
                articleManifest: articleManifest,
                articleAemImportDownloader: appDiContainer.articleAemImportDownloader,
                analytics: appDiContainer.analytics
            )
            let view = ArticlesView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
                        
        case .articleTappedFromArticles(let resource, let translationManifest, let articleAemImportData):
            
            let viewModel = ArticleWebViewModel(
                flowDelegate: self,
                resource: resource,
                translationManifest: translationManifest,
                articleAemImportData: articleAemImportData,
                articleAemImportDownloader: appDiContainer.articleAemImportDownloader,
                analytics: appDiContainer.analytics
            )
            
            let view = ArticleWebView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .sharedTappedFromArticle(let articleAemImportData):
            
            let viewModel = ShareArticleViewModel(
                articleAemImportData: articleAemImportData,
                analytics: appDiContainer.analytics
            )
            
            let view = ShareArticleView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        default:
            break
        }
    }
}
