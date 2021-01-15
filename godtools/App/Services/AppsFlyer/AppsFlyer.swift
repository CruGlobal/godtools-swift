//
//  AppsFlyer.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import AppsFlyerLib

class AppsFlyer: NSObject, AppsFlyerType {
    
    private let sharedAppsFlyerLib: AppsFlyerLib = AppsFlyerLib.shared()
    private let config: ConfigType
    private let deepLinkingService: DeepLinkingServiceType
    
    private var isConfigured: Bool = false
    
    required init(config: ConfigType, deepLinkingService: DeepLinkingServiceType) {
        
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
        appsFlyerLib.delegate = self
        
        if config.isDebug {
            appsFlyerLib.useUninstallSandbox = true
        }
    }
    
    func appDidBecomeActive() {
        appsFlyerLib.start()
        appsFlyerLib.isStopped = false
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

extension AppsFlyer: AppsFlyerLibDelegate {
    func onAppOpenAttribution(_ data: [AnyHashable : Any]) {
        
        deepLinkingService.processAppsflyerDeepLink(data: data)
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deep Link: \(error)")
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        
        deepLinkingService.processAppsflyerDeepLink(data: data)
    }
    
    func onConversionDataFail(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deferred Deep Link: \(error)")
    }
}
