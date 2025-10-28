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

class ArticleFlow: Flow {
    
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
            articleManifestAemRepository: appDiContainer.dataLayer.getArticleManifestAemRepository()
        )
        
        downloadArticlesObservable.downloadArticles(
            downloadCachePolicy: .fetchFromCacheUpToNextHour,
            forceFetchFromRemote: false
        )
        
        let viewModel = ArticleCategoriesViewModel(
            flowDelegate: self,
            resource: toolTranslations.tool,
            language: languageTranslationManifest.language,
            manifest: languageTranslationManifest.manifest,
            downloadArticlesObservable: downloadArticlesObservable,
            manifestResourcesCache: appDiContainer.getMobileContentRendererManifestResourcesCache(),
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let view = ArticleCategoriesView(
            viewModel: viewModel,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        sharedNavigationController.pushViewController(view, animated: true)
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
                        
        case .articleTappedFromArticles(let resource, let aemCacheObject):
            
            let view = getArticle(resource: resource, aemCacheObject: aemCacheObject)
            
            navigationController.pushViewController(view, animated: true)
            
        case .backTappedFromArticle:
            navigationController.popViewController(animated: true)
            
        case .sharedTappedFromArticle(let articleAemData):
            
            let viewModel = ShareArticleViewModel(
                articleAemData: articleAemData,
                trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
                trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
            )
            
            let view = ShareArticleView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .debugTappedFromArticle(let article):
            
            navigationController.present(getArticleDebugView(article: article), animated: true)
            
        case .closeTappedFromArticleDebug:
            navigationController.dismissPresented(animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension ArticleFlow {
    
    private func getArticles(resource: ResourceDataModel, language: LanguageDataModel, category: GodToolsShared.Category, manifest: Manifest) -> UIViewController {
        
        let viewModel = ArticlesViewModel(
            flowDelegate: self,
            resource: resource,
            language: language,
            category: category,
            manifest: manifest,
            downloadArticlesObservable: downloadArticlesObservable,
            articleManifestAemRepository: appDiContainer.dataLayer.getArticleManifestAemRepository(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let view = ArticlesView(
            viewModel: viewModel,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
                
        return view
    }
    
    private func getArticle(resource: ResourceDataModel, aemCacheObject: ArticleAemCacheObject) -> UIViewController {
        
        let viewModel = ArticleWebViewModel(
            flowDelegate: self,
            flowType: .tool(resource: resource),
            aemCacheObject: aemCacheObject,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            getAppUIDebuggingIsEnabledUseCase: appDiContainer.domainLayer.getAppUIDebuggingIsEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
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
    
    private func getArticleDebugView(article: ArticleDomainModel) -> UIViewController {
        
        let viewModel = ArticleDebugViewModel(
            flowDelegate: self,
            article: article
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
