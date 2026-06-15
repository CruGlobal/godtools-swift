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
                        
    init(appDiContainer: AppDiContainer, aemUri: String) {
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getArticleWebView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                articleId: aemUri
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
    
    private static func getArticleWebView(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter, articleId: String) -> UIViewController {
        
        let viewModel = ArticleWebViewModel(
            stepEmitter: stepEmitter,
            flowType: .deeplink,
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
    
        let view = ArticleWebView(
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
}
