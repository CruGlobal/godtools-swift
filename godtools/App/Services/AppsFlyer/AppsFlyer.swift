//
//  AppsFlyer.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import AppsFlyerLib

class AppsFlyer: NSObject {
    
    private let sharedAppsFlyerLib: AppsFlyerLib = AppsFlyerLib.shared()
    private let config: AppConfig
    private let deepLinkingService: DeepLinkingServiceType
    
    private var isConfigured: Bool = false
    
    required init(config: AppConfig, deepLinkingService: DeepLinkingServiceType) {
        
        self.config = config
        self.deepLinkingService = deepLinkingService
        
        super.init()
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
    
    func configure() {
        
        if isConfigured {
            return
        }
        
        isConfigured = true
                
        appsFlyerLib.appsFlyerDevKey = config.appsFlyerDevKey
        appsFlyerLib.appleAppID = config.appleAppId
        appsFlyerLib.oneLinkCustomDomains = ["get.godtoolsapp.com"]
        appsFlyerLib.deepLinkDelegate = self
        
        if config.isDebug {
            appsFlyerLib.useUninstallSandbox = true
        }
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

// MARK: - DeepLinkDelegate

extension AppsFlyer: DeepLinkDelegate {
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        
        guard let data = result.deepLink?.clickEvent else {
            return
        }
        
        _ = deepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .appsFlyer(data: data))
    }
}
