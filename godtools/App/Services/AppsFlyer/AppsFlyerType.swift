//
//  AppsFlyerType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol AppsFlyerType {
    func configure(appFlow: AppFlowType)
    func appDidBecomeActive()
    func setCustomAnalyticsData(data: [String: Any])
    func handleOpenUrl(url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    func continueUserActivity(userActivity: NSUserActivity)
    func registerUninstall (deviceToken: Data)
    func handlePushNotification(userInfo: [AnyHashable : Any])
    func logEvent(eventName: String, data: [String: Any]?)
}
