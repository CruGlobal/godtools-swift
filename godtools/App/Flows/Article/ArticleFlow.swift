//
//  ArticleFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import SwiftUI

final class ArticleFlow: GTFlow {

    enum CompletedState: Sendable {
        case articleShared
        case closed
    }

    init(
        appDiContainer: AppDiContainer,
        flowType: ArticleViewModel.FlowType,
        aemUri: String,
        article: ArticleDomainModel
    ) {

        let stepEmitter = FlowStepEmitter()

        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getArticleWebView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                flowType: flowType,
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

    private func completeFlow(state: ArticleFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.articleFlowCompleted(state: state))
    }
}

extension ArticleFlow {

    private static func getArticleWebView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        flowType: ArticleViewModel.FlowType,
        articleId: String,
        article: ArticleDomainModel
    ) -> UIViewController {

        let viewModel = ArticleViewModel(
            stepEmitter: stepEmitter,
            flowType: flowType,
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
