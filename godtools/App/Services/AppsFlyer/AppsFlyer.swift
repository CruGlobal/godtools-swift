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
    
    private let config: ConfigType
    private let deepLinkingService: DeepLinkingServiceType
    private var appFlow: AppFlowType?
    
    private var isConfigured: Bool = false
    
    required init(config: ConfigType, deepLinkingService: DeepLinkingServiceType) {
        self.config = config
        self.deepLinkingService = deepLinkingService
        
        super.init()
        
        AppsFlyerLib.shared().delegate = self
    }
    
    func configure(appFlow: AppFlowType) {
        self.appFlow = appFlow
        
        if isConfigured {
            return
        }
                
        AppsFlyerLib.shared().appsFlyerDevKey = config.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = config.appleAppId
        
        if config.isDebug {
            AppsFlyerLib.shared().useUninstallSandbox = true
        }
        
        isConfigured = true
    }
    
    func appDidBecomeActive() {
        AppsFlyerLib.shared().start()
        AppsFlyerLib.shared().isStopped = false
    }
    
    func setCustomAnalyticsData(data: [AnyHashable : Any]) {
        AppsFlyerLib.shared().customData = data
    }
    
    func getCustomAnalyticsData() -> [AnyHashable : Any]? {
        return AppsFlyerLib.shared().customData
    }
    
    func logEvent(eventName: String, data: [String : Any]?) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: data)
    }
    
    func handleOpenUrl(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }
    
    func continueUserActivity(userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity)
    }
    
    func registerUninstall(deviceToken: Data) {
        AppsFlyerLib.shared().registerUninstall(deviceToken)
    }
    
    func handlePushNotification(userInfo: [AnyHashable : Any]) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
}

extension AppsFlyer: AppsFlyerLibDelegate {
    func onAppOpenAttribution(_ data: [AnyHashable : Any]) {
        
        appFlow?.navigate(step: .showTools(animated: true, shouldCreateNewInstance: true))
        
        deepLinkingService.processAppsflyerDeepLink(data: data)
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deep Link: \(error)")
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        
        appFlow?.navigate(step: .showTools(animated: true, shouldCreateNewInstance: true))
        
        deepLinkingService.processAppsflyerDeepLink(data: data)
    }
    
    func onConversionDataFail(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deferred Deep Link: \(error)")
    }
}
