//
//  ArticleDeepLinkFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ArticleDeepLinkFlow: Flow {
    
    private let aemUri: String
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppLayoutDirectionBasedNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppLayoutDirectionBasedNavigationController, aemUri: String) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.aemUri = aemUri
        
        let articleAemRepository: ArticleAemRepository = appDiContainer.dataLayer.getArticleAemRepository()
        
        if let aemCacheObject = articleAemRepository.getAemCacheObject(aemUri: aemUri) {
            
            navigateToArticleWebView(aemCacheObject: aemCacheObject, animated: true)
        }
        else {
            
            let viewModel = LoadingArticleViewModel(
                flowDelegate: self,
                aemUri: aemUri,
                articleAemRepository: articleAemRepository,
                localizationServices: appDiContainer.dataLayer.getLocalizationServices()
            )
            
            let view = LoadingArticleView(viewModel: viewModel)
            
            sharedNavigationController.present(view, animated: true, completion: nil)
        }
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .didDownloadArticleFromLoadingArticle(let aemCacheObject):
            navigateToArticleWebView(aemCacheObject: aemCacheObject, animated: false)
            navigationController.dismiss(animated: true, completion: nil)
            
        case .didFailToDownloadArticleFromLoadingArticle(let alertMessage):
            
            let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
            
            navigationController.dismiss(animated: true) { [weak self] in
                
                let viewModel = AlertMessageViewModel(
                    title: alertMessage.title,
                    message: alertMessage.message,
                    cancelTitle: nil,
                    acceptTitle: localizationServices.stringForSystemElseEnglish(key: "OK"),
                    acceptHandler: nil
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                self?.navigationController.present(view.controller, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    private func navigateToArticleWebView(aemCacheObject: ArticleAemCacheObject, animated: Bool) {
       
        let viewModel = ArticleWebViewModel(
            flowDelegate: self,
            flowType: .deeplink,
            aemCacheObject: aemCacheObject,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase(),
            getAppUIDebuggingIsEnabledUseCase: appDiContainer.domainLayer.getAppUIDebuggingIsEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
    
        let view = ArticleWebView(viewModel: viewModel)
    
        navigationController.pushViewController(view, animated: animated)
    }
}
