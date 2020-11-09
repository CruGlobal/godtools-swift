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
    private let snowplowAnalytics: SnowplowAnalyticsType
    
    required init(adobeAnalytics: AdobeAnalyticsType, snowplowAnalytics: SnowplowAnalyticsType) {
        self.adobeAnalytics = adobeAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]?) {
        adobeAnalytics.trackAction(screenName: screenName, actionName: actionName, data: data)
        snowplowAnalytics.trackAction(action: actionName)
    }
}
