//
//  ArticleFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ArticleFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, toolTranslations: ToolTranslationsDomainModel) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let languageTranslationManifest: MobileContentRendererLanguageTranslationManifest = toolTranslations.languageTranslationManifests[0]
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: toolTranslations.tool,
            language: languageTranslationManifest.language,
            manifest: languageTranslationManifest.manifest,
            articleManifestAemRepository: appDiContainer.dataLayer.getArticleManifestAemRepository(),
            manifestResourcesCache: appDiContainer.getManifestResourcesCache(),
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics()
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
        
        case .articleCategoryTappedFromArticleCategories(let resource, let language, let category, let manifest, let currentArticleDownloadReceipt):
            
            let view = getArticles(resource: resource, language: language, category: category, manifest: manifest, currentArticleDownloadReceipt: currentArticleDownloadReceipt)
            
            navigationController.pushViewController(view, animated: true)
            
        case .backTappedFromArticles:
            navigationController.popViewController(animated: true)
                        
        case .articleTappedFromArticles(let resource, let aemCacheObject):
            
            let view = getArticle(resource: resource, aemCacheObject: aemCacheObject)
            
            navigationController.pushViewController(view, animated: true)
            
        case .backTappedFromArticle:
            navigationController.popViewController(animated: true)
            
        case .sharedTappedFromArticle(let articleAemData):
            
            let viewModel = ShareArticleViewModel(
                articleAemData: articleAemData,
                getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
                getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
                analytics: appDiContainer.dataLayer.getAnalytics()
            )
            
            let view = ShareArticleView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension ArticleFlow {
    
    func getArticles(resource: ResourceModel, language: LanguageModel, category: GodToolsToolParser.Category, manifest: Manifest, currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?) -> UIViewController {
        
        let viewModel = ArticlesViewModel(
            flowDelegate: self,
            resource: resource,
            language: language,
            category: category,
            manifest: manifest,
            articleManifestAemRepository: appDiContainer.dataLayer.getArticleManifestAemRepository(),
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            currentArticleDownloadReceipt: currentArticleDownloadReceipt
        )
        
        let view = ArticlesView(viewModel: viewModel)
        
        _ = view.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return view
    }
    
    func getArticle(resource: ResourceModel, aemCacheObject: ArticleAemCacheObject) -> UIViewController {
        
        let viewModel = ArticleWebViewModel(
            flowDelegate: self,
            aemCacheObject: aemCacheObject,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            flowType: .tool(resource: resource)
        )
        
        let view = ArticleWebView(viewModel: viewModel)
        
        _ = view.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return view
    }
}
