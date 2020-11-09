//
//  AppsFlyerType.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AppsFlyerType {
    
    func configure(adobeAnalytics: AdobeAnalyticsType)
    func trackAppLaunch()
    func trackEvent(eventName: String, data: [AnyHashable: Any]?)
    func handleOpenUrl(url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
}
