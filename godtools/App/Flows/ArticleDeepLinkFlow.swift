//
//  ArticleDeepLinkFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleDeepLinkFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
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
        // TODO: add a loading screen while downloading ~Robert
    }
    
    private func downloadFailed() {
        
    }
    
    private func handleDownloadResult(result: ArticleAemModel) {
        
        navigateToArticleWebView(articleAemData: result)
        /*switch result {
        case .success(let articleAemData):
            navigateToArticleWebView(articleAemData: articleAemData)
            
        case .failure( _):
            downloadFailed()
            
        }*/
    }
    
    private func navigateToArticleWebView(articleAemData: ArticleAemModel) {
        DispatchQueue.main.async {

            let viewModel = ArticleWebViewModel(
                flowDelegate: self,
                articleAemImportData: articleAemData.importData,
                articleAemRepository: self.appDiContainer.articleAemRepository,
                analytics: self.appDiContainer.analytics
            )
        
            let view = ArticleWebView(viewModel: viewModel)
        
            self.navigationController.pushViewController(view, animated: true)
        }
    }
}
