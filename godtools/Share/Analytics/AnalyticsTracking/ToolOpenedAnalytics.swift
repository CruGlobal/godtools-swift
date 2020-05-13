//
//  ToolOpenedAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolOpenedAnalytics {
    
    private let keyFirstToolOpened: String = "toolOpenedAnalytics.keyFirstToolOpened"
    private let analytics: AnalyticsContainer
    
    required init(analytics: AnalyticsContainer) {
        self.analytics = analytics
    }
    
    func trackToolOpened() {
        var eventName = "tool-opened"
        
        analytics.appsFlyer.trackEvent(eventName: eventName, data: nil)
        analytics.snowplowAnalytics.trackAction(action: eventName, data: nil)
    }
    
    func trackFirstToolOpenedIfNeeded() {
        
        if !firstToolOpened {
            var eventName = "first-tool-opened"
            
            analytics.appsFlyer.trackEvent(eventName: "first-tool-opened", data: nil)
            analytics.snowplowAnalytics.trackAction(action: eventName, data: nil)
            
            defaults.set(true, forKey: keyFirstToolOpened)
            defaults.synchronize()
        }
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private var firstToolOpened: Bool {
        return (defaults.object(forKey: keyFirstToolOpened) as? Bool) ?? false
    }
}
