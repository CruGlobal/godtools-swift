//
//  ArticleCategoriesFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import SwiftUI
import Flow

final class ArticleCategoriesFlow: GTFlow {
    
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
                
                pushFlow(
                    flow: ArticleFlow(
                        appDiContainer: appDiContainer,
                        flowType: .tool(resource: resource),
                        aemUri: articleId,
                        article: article
                    )
                )
            }
            
        case .articleFlowCompleted(let state):
            
            switch state {
                
            case .articleShared:
                completeFlow(state: .articleShared)
                
            case .closed:
                popFlow()
            }
            
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.articleCategoriesFlowCompleted(state: state))
    }
}

extension ArticleCategoriesFlow {
    
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
    
    private func getArticlesView(
        resource: ResourceDataModel,
        language: LanguageDataModel,
        category: ArticleCategoryDomainModel,
        manifest: Manifest
    ) -> UIViewController {
        
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
}
