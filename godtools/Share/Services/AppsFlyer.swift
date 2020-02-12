//
//  AppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import AppsFlyerLib

protocol AppsFlyerType {
    
    func configure()
    func trackAppLaunch()
    func trackEvent(eventName: String, data: [AnyHashable: Any]?)
}

class AppsFlyer: NSObject, AppsFlyerType {
    
    private let config: ConfigType
    
    private var isConfigured: Bool = false
    
    required init(config: ConfigType) {
        
        self.config = config
        
        super.init()
    }
    
    func configure() {
        if isConfigured {
            return
        }
        isConfigured = true
        
        let sharedAppsFlyer: AppsFlyerTracker = AppsFlyerTracker.shared()
        sharedAppsFlyer.isDebug = config.isDebug
        sharedAppsFlyer.appsFlyerDevKey = config.appsFlyerDevKey
        sharedAppsFlyer.appleAppID = config.appleAppId
        sharedAppsFlyer.delegate = self
    }
    
    func trackAppLaunch() {
        
        assertFailureIfNotConfigured()
        
        AppsFlyerTracker.shared().trackAppLaunch()
    }
    
    func trackEvent(eventName: String, data: [AnyHashable : Any]?) {
        
        assertFailureIfNotConfigured()
        
        AppsFlyerTracker.shared().trackEvent(eventName, withValues: data)
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AppsFlyer has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
}

extension AppsFlyer: AppsFlyerTrackerDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
}
