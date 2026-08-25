//
//  LoadingArticleFlow.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import Flow

final class LoadingArticleFlow: GTFlow {
    
    enum CompletedState {
        case downloadSuccess(aemUri: String)
        case downloadFailed(alertMessage: AlertMessage)
    }
    
    private let appLanguage: AppLanguageDomainModel
    
    init(appDiContainer: AppDiContainer, appLanguage: AppLanguageDomainModel, aemUri: String) {
        
        self.appLanguage = appLanguage
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getLoadingArticleView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                appLanguage: appLanguage,
                aemUri: aemUri
            ),
            stepEmitter: stepEmitter
        )
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }
        
        switch appStep {
        
        case .didDownloadArticleFromLoadingArticle(let aemUri):
            completeFlow(state: .downloadSuccess(aemUri: aemUri))
            
        case .didFailToDownloadArticleFromLoadingArticle(let alertMessage):
            completeFlow(state: .downloadFailed(alertMessage: alertMessage))
            
        default:
            break
        }
    }
    
    private func completeFlow(state: LoadingArticleFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.loadingArticleFlowCompleted(state: state))
    }
}

extension LoadingArticleFlow {
    
    private static func getLoadingArticleView(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter, appLanguage: AppLanguageDomainModel, aemUri: String) -> UIViewController {

        let viewModel = LoadingArticleViewModel(
            stepEmitter: stepEmitter,
            aemUri: aemUri,
            appLanguage: appLanguage,
            articleAemRepository: appDiContainer.core.dataLayer.getArticleAemRepository(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
            getDownloadArticlesErrorMessage: appDiContainer.feature.articles.domainLayer.getDownloadArticlesErrorMessage()
        )
        
        let view = LoadingArticleView(
            viewModel: viewModel
        )
        
        let navigationBar = AppNavigationBar(
            appearance: nil,
            backButton: nil,
            leadingItems: [],
            trailingItems: []
        )
        
        let hostingView = AppHostingController<LoadingArticleView>(rootView: view, navigationBar: navigationBar)
        
        hostingView.modalPresentationStyle = .overCurrentContext
        
        return hostingView
    }
}
