//
//  ArticleFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: ResourceModel, translationManifest: TranslationManifestData) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: resource,
            translationManifest: translationManifest,
            articleManifestAemRepository: appDiContainer.getArticleManifestAemRepository(),
            translationsFileCache: appDiContainer.translationsFileCache,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics
        )
        
        let view = ArticleCategoriesView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .backTappedFromArticleCategories:
            flowDelegate?.navigate(step: .articleFlowCompleted(state: .userClosedArticle))
        
        case .articleCategoryTappedFromArticleCategories(let resource, let translationZipFile, let category, let articleManifest, let currentArticleDownloadReceipt):
            
            let viewModel = ArticlesViewModel(
                flowDelegate: self,
                resource: resource,
                translationZipFile: translationZipFile,
                category: category,
                articleManifest: articleManifest,
                articleManifestAemRepository: appDiContainer.getArticleManifestAemRepository(),
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics,
                currentArticleDownloadReceipt: currentArticleDownloadReceipt
            )
            let view = ArticlesView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
                        
        case .articleTappedFromArticles(let resource, let aemCacheObject):
            
            let viewModel = ArticleWebViewModel(
                flowDelegate: self,
                aemCacheObject: aemCacheObject,
                analytics: appDiContainer.analytics,
                flowType: .tool(resource: resource)
            )
            
            let view = ArticleWebView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .sharedTappedFromArticle(let articleAemData):
            
            let viewModel = ShareArticleViewModel(
                articleAemData: articleAemData,
                analytics: appDiContainer.analytics
            )
            
            let view = ShareArticleView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

