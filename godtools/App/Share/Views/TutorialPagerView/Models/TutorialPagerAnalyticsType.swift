//
//  TutorialPagerAnalyticsType.swift
//  godtools
//
//  Created by Robert Eldredge on 9/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TutorialPagerAnalyticsType {
    
    var analyticsContainer: AnalyticsContainer { get }
    var analyticsScreenName: String { get }
    var pageCount: Int { get }
    
    func trackPageDidAppear(page: Int)
    func trackContinueButtonTapped(page: Int)
    func trackVideoWatched(videoId: String)
}

extension TutorialPagerAnalyticsType {
    
    func trackPageDidAppear (page: Int) {
        analyticsContainer.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: "\(analyticsScreenName)-\(page)", siteSection: "onboarding", siteSubSection: ""))
    }
    
    func trackContinueButtonTapped (page: Int) {
        
        let nextPage = page + 1
        let reachedEnd = nextPage >= pageCount
        
        if reachedEnd {
            analyticsContainer.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: "\(analyticsScreenName)-\(page)", actionName: "On-Boarding Start", siteSection: "", siteSubSection: "", url: nil, data: ["cru.onboarding_start": 1]))
        }
    }
    
    func trackVideoWatched(videoId: String) {
        //Make optional
    }
}
