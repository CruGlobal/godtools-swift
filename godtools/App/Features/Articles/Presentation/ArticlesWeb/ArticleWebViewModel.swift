//
//  ArticleWebViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit
import Combine

class ArticleWebViewModel: NSObject {
    
    private let aemCacheObject: ArticleAemCacheObject
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase
    private let analytics: AnalyticsContainer
    private let flowType: ArticleWebViewModelFlowType
    
    private var loadingCurrentWebView: WKWebView?
    
    private weak var flowDelegate: FlowDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesShareButton: ObservableValue<Bool> = ObservableValue(value: false)
    let hidesDebugButton: ObservableValue<Bool> = ObservableValue(value: true)
    let viewState: ObservableValue<ArticleWebViewState> = ObservableValue(value: .loadingArticle)
    
    init(flowDelegate: FlowDelegate, aemCacheObject: ArticleAemCacheObject, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, incrementUserCounterUseCase: IncrementUserCounterUseCase, getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase, analytics: AnalyticsContainer, flowType: ArticleWebViewModelFlowType) {
        
        self.flowDelegate = flowDelegate
        self.aemCacheObject = aemCacheObject
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.getAppUIDebuggingIsEnabledUseCase = getAppUIDebuggingIsEnabledUseCase
        self.analytics = analytics
        self.flowType = flowType
        
        super.init()
        
        navTitle.accept(value: aemCacheObject.aemData.articleJcrContent?.title ?? "")
                
        hidesShareButton.accept(value: aemCacheObject.aemData.articleJcrContent?.canonical == nil)
        
        getAppUIDebuggingIsEnabledUseCase.getIsEnabledPublisher()
            .receiveOnMain()
            .sink { [weak self] (isEnabled: Bool) in
                self?.hidesDebugButton.accept(value: !isEnabled)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stopLoadWebPage(webView: loadingCurrentWebView)
    }
    
    private var analyticsScreenName: String {
        return "Article : \(aemCacheObject.aemData.articleJcrContent?.title ?? "")"
    }
    
    private var analyticsSiteSection: String {
        let siteSection: String
        
        switch flowType {
        
        case .deeplink:
            siteSection = "articles"
        
        case .tool(let resource):
            siteSection = resource.abbreviation
        }
        
        return siteSection
    }
    
    private var analyticsSiteSubSection: String {
        return "article"
    }
    
    private func reloadWebPage(webView: WKWebView, shouldLoadFromFile: Bool) {
        
        stopLoadWebPage(webView: loadingCurrentWebView)
        self.loadingCurrentWebView = webView
        
        viewState.accept(value: .loadingArticle)
                
        webView.navigationDelegate = self
        
        if let webUrl = URL(string: aemCacheObject.aemData.webUrl), !shouldLoadFromFile {
            
            webView.load(URLRequest(url: webUrl))
        }
        else if let webFileUrl = aemCacheObject.webArchiveFileUrl {
            
            webView.loadFileURL(webFileUrl, allowingReadAccessTo: webFileUrl)
        }
        else {
            
            let errorTitle: String = "Internal Error"
            let errorMessage: String = "Failed to load article webview.  Missing valid webUrl and webFileUrl."
            
            viewState.accept(value: .errorMessage(title: errorTitle, message: errorMessage))
        }
    }
    
    private func stopLoadWebPage(webView: WKWebView?) {
        
        guard let webView = webView else {
            return
        }
        
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

// MARK: - Inputs

extension ArticleWebViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromArticle)
    }

    func pageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
                
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        
        incrementUserCounterUseCase.incrementUserCounter(for: .articleOpen(uri: aemCacheObject.aemUri))
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    func debugTapped() {
        
        let url: URL?
        let urlType: ArticleUrlType?
        
        if let webUrl = URL(string: aemCacheObject.aemData.webUrl) {
            url = webUrl
            urlType = .url
        }
        else if let webArchiveFileUrl = aemCacheObject.webArchiveFileUrl {
            url = webArchiveFileUrl
            urlType = .fileUrl
        }
        else {
            url = nil
            urlType = nil
        }
        
        let article = ArticleDomainModel(url: url, urlType: urlType)
        
        flowDelegate?.navigate(step: .debugTappedFromArticle(article: article))
    }
    
    func sharedTapped() {
        flowDelegate?.navigate(step: .sharedTappedFromArticle(articleAemData: aemCacheObject.aemData))
    }
    
    func loadWebPage(webView: WKWebView) {
        reloadWebPage(webView: webView, shouldLoadFromFile: false)
    }
    
    func reloadArticleTapped(webView: WKWebView) {
        reloadWebPage(webView: webView, shouldLoadFromFile: false)
    }
}

// MARK: - WKNavigationDelegate

extension ArticleWebViewModel: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        viewState.accept(value: .viewingArticle)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                        
        let errorCode: Int = (error as NSError).code
        let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
        
        if notConnectedToNetwork {
            
            reloadWebPage(webView: webView, shouldLoadFromFile: true)
        }
        else {
            
            let errorTitle: String = "Load Article Error"
            let errorMessage: String = error.localizedDescription
            
            viewState.accept(value: .errorMessage(title: errorTitle, message: errorMessage))
        }
    }
}
