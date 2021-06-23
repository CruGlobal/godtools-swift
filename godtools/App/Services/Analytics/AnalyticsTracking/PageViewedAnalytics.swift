//
//  PageViewedAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class PageViewedAnalytics {
    
    private let firebaseAnalytics: FirebaseAnalyticsType
    private let snowplowAnalytics: SnowplowAnalyticsType
    
    required init(firebaseAnalytics: FirebaseAnalyticsType, snowplowAnalytics: SnowplowAnalyticsType) {
        
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackPageView(trackScreen: TrackScreenModel) {
                
        firebaseAnalytics.trackScreenView(
            screenName: trackScreen.screenName,
            siteSection: trackScreen.siteSection,
            siteSubSection: trackScreen.siteSubSection
        )
        
        snowplowAnalytics.trackScreenView(screenName: trackScreen.screenName)
    }
}
