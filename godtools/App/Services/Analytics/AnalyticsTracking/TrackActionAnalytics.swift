//
//  TrackActionAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TrackActionAnalytics {
    
    private let adobeAnalytics: AdobeAnalyticsType
    private let firebaseAnalytics: FirebaseAnalyticsType
    private let snowplowAnalytics: SnowplowAnalyticsType
    
    required init(adobeAnalytics: AdobeAnalyticsType, firebaseAnalytics: FirebaseAnalyticsType, snowplowAnalytics: SnowplowAnalyticsType) {
        self.adobeAnalytics = adobeAnalytics
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackAction(trackAction: TrackActionModel) {
        adobeAnalytics.trackAction(trackAction: trackAction)
        firebaseAnalytics.trackAction(trackAction: trackAction)
        snowplowAnalytics.trackAction(trackAction: trackAction)
    }
}
