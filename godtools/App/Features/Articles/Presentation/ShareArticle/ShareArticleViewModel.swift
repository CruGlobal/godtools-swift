//
//  ShareArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareArticleViewModel: ShareArticleViewModelType {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let articleAemData: ArticleAemData
    
    let shareMessage: String
    
    init(articleAemData: ArticleAemData, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer) {
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
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
    
    private var analyticsSiteSection: String {
        return "articles"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
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
    
    func articleShared() {
                
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [AnalyticsConstants.Keys.shareAction: 1]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
