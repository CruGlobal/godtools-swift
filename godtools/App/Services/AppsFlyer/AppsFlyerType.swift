//
//  AppsFlyerType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import AppsFlyerLib

protocol AppsFlyerType {
    var appsFlyerLib: AppsFlyerLib { get }
    
    func configure(appFlow: AppFlow)
    func appDidBecomeActive()
    func handleOpenUrl(url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    func continueUserActivity(userActivity: NSUserActivity)
    func registerUninstall (deviceToken: Data)
    func handlePushNotification(userInfo: [AnyHashable : Any])
}
