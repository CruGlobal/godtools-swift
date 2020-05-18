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
        
        // TODO: Need to think of how to handle grabbing the latest translation without force unwrapping. ~Levi
        // TODO: What if a translation does not exist for the provided language? ~Levi
        
        var articleTranslation: Translation?
        
        if let languageTranslation = resource.getTranslationForLanguage(language) {
            articleTranslation = languageTranslation
        }
        else if let englishLanguage = LanguagesManager().loadFromDisk(code: "en"), let englishTranslation = resource.getTranslationForLanguage(englishLanguage) {
            articleTranslation = englishTranslation
        }
        else if let firstTranslation = resource.translations.first {
            articleTranslation = firstTranslation
        }
        
        let godToolsResource: GodToolsResource = GodToolsResource(
            resource: resource,
            language: language,
            translation: articleTranslation!
        )
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: resource,
            godToolsResource: godToolsResource,
            resourceLatestTranslationServices: appDiContainer.resourceLatestTranslationServices,
            analytics: appDiContainer.analytics
        )
        
        let view = ArticleCategoriesView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)        
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .articleCategoryTappedFromArticleCategories(let resource, let godToolsResource, let category, let articleManifest):
            
            let viewModel = ArticlesViewModel(
                flowDelegate: self,
                resource: resource,
                godToolsResource: godToolsResource,
                category: category,
                articleManifest: articleManifest,
                articleAemImportService: appDiContainer.articleAemImportService,
                analytics: appDiContainer.analytics
            )
            let view = ArticlesView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
                        
        case .articleTappedFromArticles(let resource, let godToolsResource, let articleAemImportData):
            
            let viewModel = ArticleWebViewModel(
                flowDelegate: self,
                resource: resource,
                godToolsResource: godToolsResource,
                articleAemImportData: articleAemImportData,
                articleAemImportService: appDiContainer.articleAemImportService,
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
