//
//  AppsFlyer.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import AppsFlyerLib

class AppsFlyer {
    
    static let shared: AppsFlyer = AppsFlyer()
    
    private let sharedAppsFlyerLib: AppsFlyerLib = AppsFlyerLib.shared()
    
    private var isConfigured: Bool = false
    
    private init() {
        
    }
    
    var appsFlyerLib: AppsFlyerLib {
        assertFailureIfNotConfigured()
        return sharedAppsFlyerLib
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AppsFlyer has not been configured.  Be sure to call configure on application didFinishLaunching.")
        }
    }
    
    func configure(appsFlyerConfiguration: AppsFlyerConfiguration, deepLinkDelegate: DeepLinkDelegate) {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
                
        appsFlyerLib.appsFlyerDevKey = appsFlyerConfiguration.appsFlyerDevKey
        appsFlyerLib.appleAppID = appsFlyerConfiguration.appleAppId
        appsFlyerLib.oneLinkCustomDomains = ["get.godtoolsapp.com"]
        appsFlyerLib.deepLinkDelegate = deepLinkDelegate
        appsFlyerLib.useUninstallSandbox = appsFlyerConfiguration.shouldUseUninstallSandbox
    }
    
    func handleOpenUrl(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        appsFlyerLib.handleOpen(url, options: options)
    }
    
    func continueUserActivity(userActivity: NSUserActivity) {
        appsFlyerLib.continue(userActivity)
    }
    
    func registerUninstall(deviceToken: Data) {
        appsFlyerLib.registerUninstall(deviceToken)
    }
    
    func handlePushNotification(userInfo: [AnyHashable : Any]) {
        appsFlyerLib.handlePushNotification(userInfo)
    }
}
