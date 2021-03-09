//
//  ArticleDeepLinkFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleDeepLinkFlow: NSObject, Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController

        super.init()
    }
    
    func navigate(step: FlowStep) {
        switch step {
        
        case .articleDeepLinkTapped(let articleUri):
            appDiContainer.articleAemRepository.getArticleAem(aemUri: articleUri, cache: navigateToArticleWebView, downloadStarted: downloadStarted, downloadFinished: handleDownloadResult)
        
        default:
            break
            
        }
    }
    
    private func downloadStarted() {
        
    }
    
    private func downloadFailed() {
        
    }
    
    private func handleDownloadResult(result: Result<ArticleAemModel, Error>) {
        switch result {
        case .success(let articleAemData):
            navigateToArticleWebView(articleAemData: articleAemData)
            
        case .failure( _):
            downloadFailed()
            
        }
    }
    
    private func navigateToArticleWebView(articleAemData: ArticleAemModel) {
        let viewModel = ArticleWebViewModel(
            flowDelegate: self,
            articleAemImportData: articleAemData.importData,
            articleAemRepository: appDiContainer.articleAemRepository,
            analytics: appDiContainer.analytics
        )
        
        let view = ArticleWebView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
