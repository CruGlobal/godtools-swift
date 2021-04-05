//
//  ArticleWebViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleWebViewModel: ArticleWebViewModelType {
    
    private let aemCacheObject: ArticleAemCacheObject
    private let analytics: AnalyticsContainer
    private let flowType: ArticleWebViewModelFlowType
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesShareButton: ObservableValue<Bool> = ObservableValue(value: false)
    let webUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    let webArchiveUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, aemCacheObject: ArticleAemCacheObject, analytics: AnalyticsContainer, flowType: ArticleWebViewModelFlowType) {
        
        self.flowDelegate = flowDelegate
        self.aemCacheObject = aemCacheObject
        self.analytics = analytics
        self.flowType = flowType
        
        navTitle.accept(value: aemCacheObject.aemData.articleJcrContent?.title ?? "")
        
        if let webArchiveUrl = aemCacheObject.webArchiveFileUrl {
            self.webArchiveUrl.accept(value: webArchiveUrl)
        }
        else if let webUrl = URL(string: aemCacheObject.aemData.webUrl) {
            self.webUrl.accept(value: webUrl)
        }
        
        hidesShareButton.accept(value: aemCacheObject.aemData.articleJcrContent?.canonical == nil)
    }

    func pageViewed() {
        
        switch flowType {
        
        case .deeplink:
            // TODO: Analytics for deeplink? ~Levi
            break
        
        case .tool(let resource):
            analytics.pageViewedAnalytics.trackPageView(
                screenName: "Article : \(aemCacheObject.aemData.articleJcrContent?.title ?? "")",
                siteSection: resource.abbreviation,
                siteSubSection: "article"
            )
        }
    }
    
    func sharedTapped() {
        flowDelegate?.navigate(step: .sharedTappedFromArticle(articleAemData: aemCacheObject.aemData))
    }
}
