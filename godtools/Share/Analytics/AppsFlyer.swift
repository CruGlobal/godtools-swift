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
    
    private let serialQueue: DispatchQueue = DispatchQueue(label: "appsflyer.serial.queue")
    private let config: ConfigType
    private let loggingEnabled: Bool
    
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false
    
    required init(config: ConfigType, loggingEnabled: Bool) {
        
        self.config = config
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    func configure(adobeAnalytics: AdobeAnalyticsType) {
        
        if isConfigured || isConfiguring {
            return
        }
        
        isConfiguring = true
        
        let sharedAppsFlyer: AppsFlyerTracker = AppsFlyerTracker.shared()
        sharedAppsFlyer.appsFlyerDevKey = config.appsFlyerDevKey
        sharedAppsFlyer.appleAppID = config.appleAppId
        sharedAppsFlyer.delegate = self
        
        serialQueue.async { [weak self] in
                        
            sharedAppsFlyer.customData = ["marketingCloudID": adobeAnalytics.visitorMarketingCloudID]
            
            self?.isConfigured = true
            self?.isConfiguring = false
            
            self?.log(method: "configure()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    func trackAppLaunch() {
                
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            AppsFlyerTracker.shared().trackAppLaunch()
            
            self?.log(method: "trackAppLaunch()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    func trackEvent(eventName: String, data: [AnyHashable : Any]?) {
                
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            AppsFlyerTracker.shared().trackEvent(eventName, withValues: data)
            
            self?.log(method: "trackEvent()", label: "eventName", labelValue: eventName, data: data)
        }
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AppsFlyer has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    private func log(method: String, label: String?, labelValue: String?, data: [AnyHashable: Any]?) {
        
        if loggingEnabled {
            print("\nAppsFlyer \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
            if let data = data {
                print("  data: \(data)")
            }
            if let customData = AppsFlyerTracker.shared().customData {
                print("  customData: \(customData)")
            }
        }
    }
}

extension AppsFlyer: AppsFlyerTrackerDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
}
