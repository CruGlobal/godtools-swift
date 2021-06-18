//
//  AnalyticsContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AnalyticsContainer {
     
    // analytics systems
    let appsFlyerAnalytics: AppsFlyerAnalyticsType
    let firebaseAnalytics: FirebaseAnalyticsType
    let snowplowAnalytics: SnowplowAnalyticsType

    // shared analytics tracking
    let pageViewedAnalytics: PageViewedAnalytics
    let trackActionAnalytics: TrackActionAnalytics
            
    required init(
        appsFlyerAnalytics: AppsFlyerAnalyticsType,
        firebaseAnalytics: FirebaseAnalyticsType,
        snowplowAnalytics: SnowplowAnalyticsType
    ) {
        
        self.pageViewedAnalytics = PageViewedAnalytics(
            firebaseAnalytics: firebaseAnalytics,
            snowplowAnalytics: snowplowAnalytics
        )
        self.trackActionAnalytics = TrackActionAnalytics(
            firebaseAnalytics: firebaseAnalytics,
            snowplowAnalytics: snowplowAnalytics
        )

        self.appsFlyerAnalytics = appsFlyerAnalytics
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
}
