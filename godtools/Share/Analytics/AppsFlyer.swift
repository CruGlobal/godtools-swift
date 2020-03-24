//
//  AppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import AppsFlyerLib

class AppsFlyer: NSObject, AppsFlyerType {
    
    private let config: ConfigType
    private let loggingEnabled: Bool
    
    private var isConfigured: Bool = false
    
    required init(config: ConfigType, loggingEnabled: Bool) {
        
        self.config = config
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    func configure(adobeAnalytics: AdobeAnalyticsType) {
        if isConfigured {
            return
        }
        isConfigured = true
        
        let sharedAppsFlyer: AppsFlyerTracker = AppsFlyerTracker.shared()
        sharedAppsFlyer.appsFlyerDevKey = config.appsFlyerDevKey
        sharedAppsFlyer.appleAppID = config.appleAppId
        sharedAppsFlyer.customData = ["marketingCloudID": adobeAnalytics.visitorMarketingCloudID]
        sharedAppsFlyer.delegate = self
    }
    
    func trackAppLaunch() {
        
        assertFailureIfNotConfigured()
        
        AppsFlyerTracker.shared().trackAppLaunch()
    }
    
    func trackEvent(eventName: String, data: [AnyHashable : Any]?) {
        
        assertFailureIfNotConfigured()
        
        AppsFlyerTracker.shared().trackEvent(eventName, withValues: data)
        
        print("\nAppsFlyer trackEvent()")
        print("  eventName: \(eventName)")
        if let data = data {
            print("  data: \(data)")
        }
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
