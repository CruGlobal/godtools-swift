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
    let adobeAnalytics: AdobeAnalyticsType
    let appsFlyer: AppsFlyerType
    let firebaseAnalytics: FirebaseAnalyticsType
    let snowplowAnalytics: SnowplowAnalyticsType

    // shared analytics tracking
    let pageViewedAnalytics: PageViewedAnalytics
    let trackActionAnalytics: TrackActionAnalytics
    
    required init(
        adobeAnalytics: AdobeAnalyticsType,
        appsFlyer: AppsFlyerType,
        firebaseAnalytics: FirebaseAnalyticsType,
        snowplowAnalytics: SnowplowAnalyticsType
    ) {
        
        self.pageViewedAnalytics = PageViewedAnalytics(
            adobeAnalytics: adobeAnalytics,
            firebaseAnalytics: firebaseAnalytics,
            snowplowAnalytics: snowplowAnalytics
        )
        self.trackActionAnalytics = TrackActionAnalytics(
            adobeAnalytics: adobeAnalytics,
            firebaseAnalytics: firebaseAnalytics,
            snowplowAnalytics: snowplowAnalytics
        )

        self.adobeAnalytics = adobeAnalytics
        self.appsFlyer = appsFlyer
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
}
