//
//  ShareArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareArticleViewModel: ShareArticleViewModelType {
    
    private let analytics: AnalyticsContainer
    private let articleAemImportData: RealmArticleAemImportData
    
    let shareMessage: String
    
    required init(articleAemImportData: RealmArticleAemImportData, analytics: AnalyticsContainer) {
        
        self.analytics = analytics
        self.articleAemImportData = articleAemImportData
        
        // shareUrlString
        var urlString: String = articleAemImportData.articleJcrContent?.canonical ?? ""
        while urlString.last == "/" {
            urlString.removeLast()
        }
        if urlString.isEmpty {
            urlString = "https://everystudent.com"
        }
        
        let shareUrlString: String = urlString.appending("?icid=gtshare")
        
        shareMessage = shareUrlString
    }
    
    private var analyticsScreenName: String {
        return "Article : \(articleAemImportData.articleJcrContent?.title ?? "GodTools")"
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: analyticsScreenName,
            siteSection: "",
            siteSubSection: ""
        )
    }
    
    func articleShared() {
        
        let data: [String: Any] = [
            AdobeAnalyticsConstants.Keys.shareAction: 1,
            GTConstants.kAnalyticsScreenNameKey: analyticsScreenName
        ]
        
        analytics.adobeAnalytics.trackAction(
            screenName: nil,
            actionName: AdobeAnalyticsConstants.Values.share,
            data: data
        )
    }
}
