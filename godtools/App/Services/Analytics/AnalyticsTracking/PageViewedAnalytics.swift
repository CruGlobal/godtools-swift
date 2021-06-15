//
//  PageViewedAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class PageViewedAnalytics {
    
    private let adobeAnalytics: AdobeAnalyticsType
    private let firebaseAnalytics: FirebaseAnalyticsType
    private let snowplowAnalytics: SnowplowAnalyticsType
    
    required init(adobeAnalytics: AdobeAnalyticsType, firebaseAnalytics: FirebaseAnalyticsType, snowplowAnalytics: SnowplowAnalyticsType) {
        
        self.adobeAnalytics = adobeAnalytics
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackPageView(trackScreen: TrackScreenModel) {
        
        adobeAnalytics.trackScreenView(trackScreen: trackScreen)
        
        firebaseAnalytics.trackScreenView(
            screenName: trackScreen.screenName,
            siteSection: trackScreen.siteSection,
            siteSubSection: trackScreen.siteSubSection
        )
        
        snowplowAnalytics.trackScreenView(screenName: trackScreen.screenName)
    }
}
