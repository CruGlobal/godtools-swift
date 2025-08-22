//
//  ArticleDeepLinkFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Combine
import LocalizationServices

class ArticleDeepLinkFlow: Flow {
    
    private let aemUri: String
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, aemUri: String) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.aemUri = aemUri
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .flatMap(maxPublishers: .max(1)) {
                return Just($0)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                
                self?.appLanguage = appLanguage
                
                if let aemCacheObject = appDiContainer.dataLayer.getArticleAemRepository().getAemCacheObject(aemUri: aemUri) {
                    
                    self?.navigateToArticleWebView(aemCacheObject: aemCacheObject, animated: true)
                }
                else if let loadingArticleView = self?.getLoadingArticleView(appLanguage: appLanguage) {
                    
                    sharedNavigationController.present(loadingArticleView, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)
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
            
            let localizationServices: LocalizationServicesInterface = appDiContainer.dataLayer.getLocalizationServices()
            let appLanguage: AppLanguageDomainModel = self.appLanguage
            
            navigationController.dismiss(animated: true) { [weak self] in
                
                let viewModel = AlertMessageViewModel(
                    title: alertMessage.title,
                    message: alertMessage.message,
                    cancelTitle: nil,
                    acceptTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.ok.key)
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
    
    private func getLoadingArticleView(appLanguage: AppLanguageDomainModel) -> UIViewController {
        
        let viewModel = LoadingArticleViewModel(
            flowDelegate: self,
            aemUri: aemUri,
            appLanguage: appLanguage,
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
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
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
