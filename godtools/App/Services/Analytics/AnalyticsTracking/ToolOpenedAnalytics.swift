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
    private let appsFlyerAnalytics: AppsFlyerAnalyticsType
    
    required init(appsFlyerAnalytics: AppsFlyerAnalyticsType) {
        self.appsFlyerAnalytics = appsFlyerAnalytics
    }
    
    func trackToolOpened() {
        appsFlyerAnalytics.trackAction(trackAction: TrackActionModel(screenName: nil, actionName: "tool-opened", siteSection: nil, siteSubSection: nil, url: nil, data: nil))
    }
    
    func trackFirstToolOpenedIfNeeded() {
        
        if !firstToolOpened {

            appsFlyerAnalytics.trackAction(trackAction: TrackActionModel(screenName: nil, actionName: "first-tool-opened", siteSection: nil, siteSubSection: nil, url: nil, data: nil))
                        
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
