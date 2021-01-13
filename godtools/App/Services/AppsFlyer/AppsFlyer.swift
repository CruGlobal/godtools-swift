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
    
    private var appFlow: AppFlowType?
    private let deepLinkingService: DeepLinkingServiceType
    
    required init(deepLinkingService: DeepLinkingServiceType) {
        self.deepLinkingService = deepLinkingService
        
        AppsFlyerLib.shared().delegate = self
    }
    
    func configure(appFlow: AppFlowType) {
        self.appFlow = appFlow
    }
    
    func appDidBecomeActive() {
        AppsFlyerLib.shared().start()
        AppsFlyerLib.shared().isStopped = false
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
        
        appFlow.navigate(step: .showTools(animated: true, shouldCreateNewInstance: true))
        
        deepLinkingService.processAppsflyerDeepLink(data: data)
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deep Link: \(error)")
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        
        appFlow.navigate(step: .showTools(animated: true, shouldCreateNewInstance: true))
        
        deepLinkingService.processAppsflyerDeepLink(data: data)
    }
    
    func onConversionDataFail(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deferred Deep Link: \(error)")
    }
}
