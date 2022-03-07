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
    private let articleAemData: ArticleAemData
    
    let shareMessage: String
    
    required init(articleAemData: ArticleAemData, analytics: AnalyticsContainer) {
        
        self.analytics = analytics
        self.articleAemData = articleAemData
        
        // shareUrlString
        var urlString: String = articleAemData.articleJcrContent?.canonical ?? ""
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
        return "Article : \(articleAemData.articleJcrContent?.title ?? "GodTools")"
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: "", siteSubSection: ""))
    }
    
    func articleShared() {
                
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.share, siteSection: "", siteSubSection: "", url: nil, data: [AnalyticsConstants.Keys.shareAction: 1]))
    }
}
