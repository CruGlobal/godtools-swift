//
//  AppsFlyerAnalytics+MobileContentRendererAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension AppsFlyerAnalytics: MobileContentRendererAnalyticsSystem {
    
    func trackMobileContentAction(screenName: String, siteSection: String, action: String, data: [String: Any]?) {
        trackAction(actionName: action, data: data)
    }
}
