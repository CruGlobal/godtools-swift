//
//  ShareArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareArticleViewModel {
    
    private let articleAemData: ArticleAemData
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    let shareMessage: String
    
    init(articleAemData: ArticleAemData, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.articleAemData = articleAemData
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
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
    
    private var analyticsSiteSection: String {
        return "articles"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    func articleShared() {
                
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.shareAction: 1]
        )
    }
}
