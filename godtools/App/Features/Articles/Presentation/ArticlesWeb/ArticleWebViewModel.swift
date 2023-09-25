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
    private let flowType: ArticleWebViewModelFlowType
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let displayArticleAfterNumberOfSeconds: TimeInterval = 2
    
    private var loadingCurrentWebView: WKWebView?
    private var displayArticleTimer: Timer?
    
    private weak var flowDelegate: FlowDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesShareButton: ObservableValue<Bool> = ObservableValue(value: false)
    let hidesDebugButton: ObservableValue<Bool> = ObservableValue(value: true)
    let viewState: ObservableValue<ArticleWebViewState> = ObservableValue(value: .loadingArticle)
    
    init(flowDelegate: FlowDelegate, flowType: ArticleWebViewModelFlowType, aemCacheObject: ArticleAemCacheObject, incrementUserCounterUseCase: IncrementUserCounterUseCase, getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.flowType = flowType
        self.aemCacheObject = aemCacheObject
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.getAppUIDebuggingIsEnabledUseCase = getAppUIDebuggingIsEnabledUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init()
        
        navTitle.accept(value: aemCacheObject.aemData.articleJcrContent?.title ?? "")
                
        hidesShareButton.accept(value: aemCacheObject.aemData.articleJcrContent?.canonical == nil)
        
        getAppUIDebuggingIsEnabledUseCase.getIsEnabledPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isEnabled: Bool) in
                self?.hidesDebugButton.accept(value: !isEnabled)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stopDisplayArticleTimer()
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
        
        let webUrl: URL? = URL(string: aemCacheObject.aemData.webUrl)
        let webArchiveFileUrl: URL? = aemCacheObject.webArchiveFileUrl
        
        guard webUrl != nil || webArchiveFileUrl != nil else {
            
            let errorTitle: String = "Internal Error"
            let errorMessage: String = "Failed to load article webview.  Missing valid webUrl and webFileUrl."
            
            viewState.accept(value: .errorMessage(title: errorTitle, message: errorMessage))
            
            return
        }
        
        viewState.accept(value: .loadingArticle)
        startDispalyArticleTimer()
        webView.navigationDelegate = self
        
        if let webUrl = webUrl, !shouldLoadFromFile {
            
            webView.load(URLRequest(url: webUrl))
        }
        else if let webFileUrl = webArchiveFileUrl {
            
            webView.loadFileURL(webFileUrl, allowingReadAccessTo: webFileUrl)
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
    
    private func startDispalyArticleTimer() {
        
        stopDisplayArticleTimer()
        
        displayArticleTimer = Timer.scheduledTimer(
            timeInterval: displayArticleAfterNumberOfSeconds,
            target: self,
            selector: #selector(displayArticleTimerDidEnd),
            userInfo: nil,
            repeats: false
        )
    }
    
    private func stopDisplayArticleTimer() {
        
        displayArticleTimer?.invalidate()
        displayArticleTimer = nil
    }
    
    @objc private func displayArticleTimerDidEnd() {
        
        stopDisplayArticleTimer()
        
        loadingCurrentWebView?.navigationDelegate = nil
        viewState.accept(value: .viewingArticle)
    }
}

// MARK: - Inputs

extension ArticleWebViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromArticle)
    }

    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
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
        
        stopDisplayArticleTimer()
        
        viewState.accept(value: .viewingArticle)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             
        stopDisplayArticleTimer()
        
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
