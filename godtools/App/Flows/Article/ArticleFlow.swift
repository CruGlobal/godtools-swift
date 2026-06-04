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
import Combine

class ArticleFlow: LegacyFlow {
    
    private let downloadArticlesObservable: DownloadManifestArticlesObservable
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolTranslations: ToolTranslationsDomainModel) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
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
        
        sharedNavigationController.pushViewController(
            getArticleCategories(
                toolTranslations: toolTranslations,
                languageTranslationManifest: languageTranslationManifest
            ),
            animated: true
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .backTappedFromArticleCategories:
            flowDelegate?.navigate(step: .articleFlowCompleted(state: .userClosedArticle))
        
        case .articleCategoryTappedFromArticleCategories(let resource, let language, let category, let manifest):
            
            let view = getArticles(resource: resource, language: language, category: category, manifest: manifest)
            
            navigationController.pushViewController(view, animated: true)
            
        case .backTappedFromArticles:
            navigationController.popViewController(animated: true)
                        
        case .articleTappedFromArticles(let resource, let articleId):
            
            let view = getArticle(resource: resource, articleId: articleId)
            
            navigationController.pushViewController(view, animated: true)
            
        case .backTappedFromArticle:
            navigationController.popViewController(animated: true)
            
        case .sharedTappedFromArticle(let articleId):
            
            let viewModel = ShareArticleViewModel(
                articleId: articleId,
                shareArticleUseCase: appDiContainer.feature.articles.domainLayer.getShareArticleUseCase(),
                trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
                trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
            )
            
            let view = ShareArticleView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .debugTappedFromArticle(let articleUrl):
            
            navigationController.present(getArticleDebugView(articleUrl: articleUrl), animated: true)
            
        case .closeTappedFromArticleDebug:
            navigationController.dismissPresented(animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension ArticleFlow {
    
    private func getArticleCategories(toolTranslations: ToolTranslationsDomainModel, languageTranslationManifest: MobileContentRendererLanguageTranslationManifest) -> UIViewController {
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
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
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )

        let viewContoller = AppHostingController(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return viewContoller
    }
    
    private func getArticles(resource: ResourceDataModel, language: LanguageDataModel, category: ArticleCategoryDomainModel, manifest: Manifest) -> UIViewController {
        
        let viewModel = ArticlesViewModel(
            flowDelegate: self,
            resource: resource,
            language: language,
            category: category,
            manifest: manifest,
            downloadArticlesObservable: downloadArticlesObservable,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getArticlesUseCase: appDiContainer.feature.articles.domainLayer.getArticlesUseCase(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let view = ArticlesView(
            viewModel: viewModel
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let navigationBar = AppNavigationBar(
            appearance: nil,
            backButton: backButton,
            leadingItems: [],
            trailingItems: []
        )
        
        let hostingView = AppHostingController<ArticlesView>(rootView: view, navigationBar: navigationBar)
        
        return hostingView
    }
    
    private func getArticle(resource: ResourceDataModel, articleId: String) -> UIViewController {
        
        let viewModel = ArticleWebViewModel(
            flowDelegate: self,
            flowType: .tool(resource: resource),
            articleId: articleId,
            getArticleUseCase: appDiContainer.feature.articles.domainLayer.getArticleUseCase(),
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            getAppUIDebuggingIsEnabledUseCase: appDiContainer.core.domainLayer.getAppUIDebuggingIsEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let shareButton = AppShareBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.sharedTapped),
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesShareButton.eraseToAnyPublisher()
        )
        
        let debugButton = AppDebugBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.debugTapped),
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesDebugButton.eraseToAnyPublisher()
        )
        
        let view = ArticleWebView(
            viewModel: viewModel,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: [debugButton, shareButton]
            )
        )
        
        return view
    }
    
    private func getArticleDebugView(articleUrl: ArticleUrlDomainModel) -> UIViewController {
        
        let viewModel = ArticleDebugViewModel(
            flowDelegate: self,
            articleUrl: articleUrl
        )
        
        let view = ArticleDebugView(viewModel: viewModel)
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let hostingView = AppHostingController<ArticleDebugView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        let modal = ModalNavigationController.defaultModal(rootView: hostingView, statusBarStyle: .default)
        
        return modal
    }
}
