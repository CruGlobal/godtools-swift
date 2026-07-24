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

@MainActor
final class ArticleWebViewModel: NSObject, ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let articleId: String
    private let article: ArticleDomainModel
    private let flowType: ArticleWebViewModelFlowType
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let displayArticleAfterNumberOfSeconds: TimeInterval = 2
    
    private var loadingCurrentWebView: WKWebView?
    private var loadingArticle: ArticleUrlDomainModel?
    private var displayArticleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
        
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let viewState: ObservableValue<ArticleWebViewState> = ObservableValue(value: .loadingArticle)
        
    @Published private(set) var hidesShareButton: Bool = false
    @Published private(set) var hidesDebugButton: Bool = true
    
    init(
        stepEmitter: FlowStepEmitter,
        flowType: ArticleWebViewModelFlowType,
        articleId: String,
        article: ArticleDomainModel,
        incrementUserCounterUseCase: IncrementUserCounterUseCase,
        getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.flowType = flowType
        self.articleId = articleId
        self.article = article
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.getAppUIDebuggingIsEnabledUseCase = getAppUIDebuggingIsEnabledUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init()
    
        navTitle.accept(value: article.title)
              
        hidesShareButton = !article.isShareable
        
        hidesDebugButton = !getAppUIDebuggingIsEnabledUseCase.execute()
    }
    
    @MainActor deinit {
        print("x deinit: \(type(of: self))")
        stopDisplayArticleTimer()
        stopLoadWebPage(webView: loadingCurrentWebView)
    }
    
    private var analyticsScreenName: String {
        return "Article : \(article.title)"
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
        
        let httpsArticleUrl: ArticleUrlDomainModel? = article.httpsUrl
        let archiveFileUrl: ArticleUrlDomainModel? = article.archiveUrl
                
        guard httpsArticleUrl != nil || archiveFileUrl != nil else {
            
            let errorTitle: String = "Internal Error"
            let errorMessage: String = "Failed to load article webview.  Missing valid webUrl and webFileUrl."
            
            viewState.accept(value: .errorMessage(title: errorTitle, message: errorMessage))
            
            return
        }
        
        viewState.accept(value: .loadingArticle)
        startDispalyArticleTimer()
        webView.navigationDelegate = self
        
        if let url = httpsArticleUrl?.url, !shouldLoadFromFile {

            loadingArticle = httpsArticleUrl
            
            webView.load(URLRequest(url: url))
        }
        else if let url = archiveFileUrl?.url {
            
            loadingArticle = archiveFileUrl
            
            webView.loadFileURL(url, allowingReadAccessTo: url)
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
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromArticle)
    }

    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        incrementUserCounterUseCase
            .execute(
                interaction: .articleOpen(uri: articleId)
            )
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    @objc func debugTapped() {
        
        guard let articleUrl = loadingArticle else {
            return
        }
        
        stepEmitter.emit(step: AppFlowStep.debugTappedFromArticle(articleUrl: articleUrl))
    }
    
    @objc func sharedTapped() {
        stepEmitter.emit(step: AppFlowStep.sharedTappedFromArticle(articleId: articleId))
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        
        stopDisplayArticleTimer()
        
        viewState.accept(value: .viewingArticle)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
             
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
