//
//  ArticleWebViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit

class ArticleWebViewModel: NSObject, ArticleWebViewModelType {
    
    private let aemCacheObject: ArticleAemCacheObject
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let flowType: ArticleWebViewModelFlowType
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesShareButton: ObservableValue<Bool> = ObservableValue(value: false)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    
    init(flowDelegate: FlowDelegate, aemCacheObject: ArticleAemCacheObject, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, flowType: ArticleWebViewModelFlowType) {
        
        self.flowDelegate = flowDelegate
        self.aemCacheObject = aemCacheObject
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.flowType = flowType
        
        super.init()
        
        navTitle.accept(value: aemCacheObject.aemData.articleJcrContent?.title ?? "")
                
        hidesShareButton.accept(value: aemCacheObject.aemData.articleJcrContent?.canonical == nil)
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

    func pageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
                
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
    
    func sharedTapped() {
        flowDelegate?.navigate(step: .sharedTappedFromArticle(articleAemData: aemCacheObject.aemData))
    }
    
    func loadWebPage(webView: WKWebView) {
        loadWebPage(webView: webView, shouldLoadFromFile: false)
    }
    
    private func loadWebPage(webView: WKWebView, shouldLoadFromFile: Bool) {
        
        isLoading.accept(value: true)
        
        webView.navigationDelegate = self
        
        if let webUrl = URL(string: aemCacheObject.aemData.webUrl), !shouldLoadFromFile {
            webView.load(URLRequest(url: webUrl))
        }
        else if let webFileUrl = aemCacheObject.webArchiveFileUrl {
            webView.loadFileURL(webFileUrl, allowingReadAccessTo: webFileUrl)
        }
    }
}

extension ArticleWebViewModel: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        isLoading.accept(value: false)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                
        let errorCode: Int = (error as NSError).code
        let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
        
        if notConnectedToNetwork {
            webView.stopLoading()
            loadWebPage(webView: webView, shouldLoadFromFile: true)
        }
    }
}
