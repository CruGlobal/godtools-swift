//
//  WebContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebContentViewModel: WebContentViewModelType {
    
    private let analytics: AnalyticsContainer
    private let webContent: WebContentType
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let url: ObservableValue<URL?> = ObservableValue(value: nil)
    
    required init(analytics: AnalyticsContainer, webContent: WebContentType) {
        
        self.analytics = analytics
        self.webContent = webContent
        
        navTitle.accept(value: webContent.navTitle)
        url.accept(value: webContent.url)
    }
    
    private var analyticsScreenName: String {
        return webContent.analyticsScreenName
    }
    
    private var analyticsSiteSection: String {
        return webContent.analyticsSiteSection
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}
