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
    private let resource: ResourceModel
    private let translationManifest: TranslationManifestData
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: ResourceModel, translationManifest: TranslationManifestData) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.resource = resource
        self.translationManifest = translationManifest
        self.navigationController = sharedNavigationController
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: resource,
            translationManifest: translationManifest,
            articleAemImportDownloader: appDiContainer.articleAemImportDownloader,
            translationsFileCache: appDiContainer.translationsFileCache,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics
        )
        
        let view = ArticleCategoriesView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .articleCategoryTappedFromArticleCategories(let resource, let translationZipFile, let category, let articleManifest):
            
            let viewModel = ArticlesViewModel(
                flowDelegate: self,
                resource: resource,
                translationZipFile: translationZipFile,
                category: category,
                articleManifest: articleManifest,
                articleAemImportDownloader: appDiContainer.articleAemImportDownloader,
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics
            )
            let view = ArticlesView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
                        
        case .articleTappedFromArticles(let resource, let translationZipFile, let articleAemImportData):
            
            let viewModel = ArticleWebViewModel(
                flowDelegate: self,
                resource: resource,
                translationZipFile: translationZipFile,
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
            
        case .articleDeepLinkTapped(let resource, let translationZipFile, let articleAemImportData):
            
            let viewModel = ArticleWebViewModel(
                flowDelegate: self,
                resource: resource,
                translationZipFile: translationZipFile,
                articleAemImportData: articleAemImportData,
                articleAemImportDownloader: appDiContainer.articleAemImportDownloader,
                analytics: appDiContainer.analytics
            )
            
            let view = ArticleWebView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        default:
            break
        }
    }
    
    func navigateToArticle(articleUri: String) {
        let translationZipFile = translationManifest.translationZipFile
        
        let importData = appDiContainer.articleAemImportDownloader.downloadAndCache(translationZipFile: translationZipFile, aemImportSrcs: [articleUri])
        
        navigate(step: .articleDeepLinkTapped(resource: resource, translationZipFile: translationManifest.translationZipFile, articleAemImportData: importData))
    }
}
