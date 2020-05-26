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
    private let appsFlyer: AppsFlyerType
    private let snowplowAnalytics: SnowplowAnalyticsType
    
    required init(appsFlyer: AppsFlyerType, snowplowAnalytics: SnowplowAnalyticsType) {
        self.appsFlyer = appsFlyer
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackToolOpened() {
       appsFlyer.trackEvent(eventName: "tool-opened", data: nil)
    }
    
    func trackFirstToolOpenedIfNeeded() {
        
        if !firstToolOpened {
            
            appsFlyer.trackEvent(eventName: "first-tool-opened", data: nil)
            
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
