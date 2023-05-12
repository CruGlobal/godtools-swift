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
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    
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
    
    private func loadWebPage(webView: WKWebView, shouldLoadFromFile: Bool) {
        
        stopLoadWebPage(webView: loadingCurrentWebView)
        self.loadingCurrentWebView = webView
        
        isLoading.accept(value: true)
        
        webView.navigationDelegate = self
        
        if let webUrl = URL(string: aemCacheObject.aemData.webUrl), !shouldLoadFromFile {
            webView.load(URLRequest(url: webUrl))
        }
        else if let webFileUrl = aemCacheObject.webArchiveFileUrl {
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
        loadWebPage(webView: webView, shouldLoadFromFile: false)
    }
}

// MARK: - WKNavigationDelegate

extension ArticleWebViewModel: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        isLoading.accept(value: false)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                        
        let errorCode: Int = (error as NSError).code
        let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
        
        if notConnectedToNetwork {
            stopLoadWebPage(webView: loadingCurrentWebView)
            loadWebPage(webView: webView, shouldLoadFromFile: true)
        }
    }
}
