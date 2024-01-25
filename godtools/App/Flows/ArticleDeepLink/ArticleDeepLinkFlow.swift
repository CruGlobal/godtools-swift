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
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, aemUri: String) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.aemUri = aemUri
                
        if let aemCacheObject = appDiContainer.dataLayer.getArticleAemRepository().getAemCacheObject(aemUri: aemUri) {
            
            navigateToArticleWebView(aemCacheObject: aemCacheObject, animated: true)
        }
        else {
            
            sharedNavigationController.present(getLoadingArticleView(), animated: true, completion: nil)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
       
        navigationController.pushViewController(getArticleWebView(aemCacheObject: aemCacheObject), animated: animated)
    }
}

extension ArticleDeepLinkFlow {
    
    private func getLoadingArticleView() -> UIViewController {
        
        let viewModel = LoadingArticleViewModel(
            flowDelegate: self,
            aemUri: aemUri,
            articleAemRepository: appDiContainer.dataLayer.getArticleAemRepository(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let navigationBar = AppNavigationBar(
            appearance: nil,
            backButton: nil,
            leadingItems: [],
            trailingItems: []
        )
        
        let view = LoadingArticleView(
            viewModel: viewModel,
            navigationBar: navigationBar
        )
        
        return view
    }
    
    private func getArticleWebView(aemCacheObject: ArticleAemCacheObject) -> UIViewController {
        
        let viewModel = ArticleWebViewModel(
            flowDelegate: self,
            flowType: .deeplink,
            aemCacheObject: aemCacheObject,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase(),
            getAppUIDebuggingIsEnabledUseCase: appDiContainer.domainLayer.getAppUIDebuggingIsEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
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
