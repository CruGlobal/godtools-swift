//
//  ArticleFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import SwiftUI

final class ArticleFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case articleShared
        case userClosed
    }
    
    private let downloadArticlesObservable: DownloadManifestArticlesObservable
                
    init(appDiContainer: AppDiContainer, toolTranslations: ToolTranslationsDomainModel) {
                
        let languageTranslationManifest: MobileContentRendererLanguageTranslationManifest = toolTranslations.languageTranslationManifests[0]
        
        downloadArticlesObservable = DownloadManifestArticlesObservable(
            translation: languageTranslationManifest.translation,
            language: languageTranslationManifest.language,
            manifest: languageTranslationManifest.manifest,
            articleManifestAemRepository: appDiContainer.core.dataLayer.getArticleManifestAemRepository()
        )
        
        downloadArticlesObservable.downloadArticles(
            downloadCachePolicy: .fetchFromCacheUpToNextHour,
            forceFetchFromRemote: false
        )
        
        let stepEmitter = FlowStepEmitter()
        
        let articleCategories = Self.getArticleCategories(
            appDiContainer: appDiContainer,
            stepEmitter: stepEmitter,
            toolTranslations: toolTranslations,
            languageTranslationManifest: languageTranslationManifest
        )
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: articleCategories,
            stepEmitter: stepEmitter
        )
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
        
        case .backTappedFromArticleCategories:
            completeFlow(state: .userClosed)
        
        case .articleCategoryTappedFromArticleCategories(let resource, let language, let category, let manifest):
            
            let view = getArticlesView(resource: resource, language: language, category: category, manifest: manifest)
            
            navigationController.pushViewController(view, animated: true)
            
        case .backTappedFromArticles:
            navigationController.popViewController(animated: true)
                        
        case .articleTappedFromArticles(let resource, let articleId):
            
            // TODO: May need to check if article needs downloading before executing use case. ~Levi
            
            Task {
                
                let getArticleUseCase = appDiContainer.feature.articles.domainLayer.getArticleUseCase()
                
                let article = try await getArticleUseCase.execute(articleId: articleId)
                
                let view = getArticleView(resource: resource, articleId: articleId, article: article)
                
                navigationController.pushViewController(view, animated: true)
            }
            
        case .backTappedFromArticle:
            navigationController.popViewController(animated: true)
            
        case .sharedTappedFromArticle(let articleId):
            
            Task {
                
                let shareArticleUseCase = appDiContainer.feature.articles.domainLayer.getShareArticleUseCase()
                
                let shareArticle = try await shareArticleUseCase.execute(
                    articleId: articleId
                )
             
                let viewModel = ShareArticleViewModel(
                    stepEmitter: stepEmitter,
                    shareArticle: shareArticle,
                    trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
                    trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
                )
                
                let view = ShareArticleView(viewModel: viewModel)
                
                presentView(view: view.controller, animated: true)
            }
            
        case .dismissedShareArticleActivityViewController:
            completeFlow(state: .articleShared)
                        
        case .debugTappedFromArticle(let articleUrl):
            
            presentView(
                view: getArticleDebugView(articleUrl: articleUrl),
                animated: true
            )
            
        case .closeTappedFromArticleDebug:
            dismissView(animated: true)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.articleFlowCompleted(state: state))
    }
}

extension ArticleFlow {
    
    private static func getArticleCategories(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        toolTranslations: ToolTranslationsDomainModel,
        languageTranslationManifest: MobileContentRendererLanguageTranslationManifest
    ) -> UIViewController {
        
        let viewModel = ArticleCategoriesViewModel(
            stepEmitter: stepEmitter,
            resource: toolTranslations.tool,
            language: languageTranslationManifest.language,
            translation: languageTranslationManifest.translation,
            manifest: languageTranslationManifest.manifest,
            getArticleCategoriesUseCase: appDiContainer.feature.articles.domainLayer.getArticleCategoriesUseCase(),
            pullToRefreshArticlesUseCase: appDiContainer.feature.articles.domainLayer.getPullToRefreshArticlesUseCase(),
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ArticleCategoriesView(viewModel: viewModel)

        let viewContoller = AppHostingController(
            rootView: view
        )
        
        return viewContoller
    }
    
    private func getArticlesView(resource: ResourceDataModel, language: LanguageDataModel, category: ArticleCategoryDomainModel, manifest: Manifest) -> UIViewController {
        
        let viewModel = ArticlesViewModel(
            stepEmitter: stepEmitter,
            resource: resource,
            language: language,
            category: category,
            manifest: manifest,
            downloadArticlesObservable: downloadArticlesObservable,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getArticlesUseCase: appDiContainer.feature.articles.domainLayer.getArticlesUseCase(),
            getDownloadArticlesErrorMessage: appDiContainer.feature.articles.domainLayer.getDownloadArticlesErrorMessage(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let view = ArticlesView(
            viewModel: viewModel
        )
        
        let hostingView = AppHostingController<ArticlesView>(rootView: view)
        
        return hostingView
    }
    
    private func getArticleView(
        resource: ResourceDataModel,
        articleId: String,
        article: ArticleDomainModel
    ) -> UIViewController {
        
        let viewModel = ArticleViewModel(
            stepEmitter: stepEmitter,
            flowType: .tool(resource: resource),
            articleId: articleId,
            article: article,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            getAppUIDebuggingIsEnabledUseCase: appDiContainer.core.domainLayer.getAppUIDebuggingIsEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            getDownloadArticlesErrorMessage: appDiContainer.feature.articles.domainLayer.getDownloadArticlesErrorMessage(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices()
        )
        
        let view = ArticleView(
            viewModel: viewModel
        )
        
        let hostingView = AppHostingController<ArticleView>(
            rootView: view
        )
        
        return hostingView
    }
    
    private func getArticleDebugView(articleUrl: ArticleUrlDomainModel) -> UIViewController {
        
        let viewModel = ArticleDebugViewModel(
            stepEmitter: stepEmitter,
            articleUrl: articleUrl
        )
        
        let view = ArticleDebugView(viewModel: viewModel)
        
        let hostingView = AppHostingController<ArticleDebugView>(
            rootView: view
        )
        
        let modal = ModalNavigationController.defaultModal(rootView: hostingView, statusBarStyle: .default)
        
        return modal
    }
}
