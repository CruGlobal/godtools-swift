//
//  ArticleDeepLinkFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

final class ArticleDeepLinkFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case closed
    }
                        
    init(appDiContainer: AppDiContainer, aemUri: String, article: ArticleDomainModel) {
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getArticleWebView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                articleId: aemUri,
                article: article
            ),
            stepEmitter: stepEmitter
        )
    }

    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .backTappedFromArticle:
            completeFlow(state: .closed)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: ArticleDeepLinkFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.articleDeepLinkFlowCompleted(state: state))
    }
}

extension ArticleDeepLinkFlow {
    
    private static func getArticleWebView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        articleId: String,
        article: ArticleDomainModel
    ) -> UIViewController {
        
        let viewModel = ArticleViewModel(
            stepEmitter: stepEmitter,
            flowType: .deeplink,
            articleId: articleId,
            article: article,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            getAppUIDebuggingIsEnabledUseCase: appDiContainer.core.domainLayer.getAppUIDebuggingIsEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            getDownloadArticlesErrorMessage: appDiContainer.feature.articles.domainLayer.getDownloadArticlesErrorMessage(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices()
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
    
        let view = ArticleView(
            viewModel: viewModel
        )
        
        let hostingView = AppHostingController<ArticleView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
}
