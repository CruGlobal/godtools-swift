//
//  AppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
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
        
        let sharedAppsFlyer: AppsFlyerLib = AppsFlyerLib.shared()
        sharedAppsFlyer.appsFlyerDevKey = config.appsFlyerDevKey
        sharedAppsFlyer.appleAppID = config.appleAppId
        
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
        
            AppsFlyerLib.shared().start()
            
            self?.log(method: "trackAppLaunch()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    func trackEvent(eventName: String, data: [AnyHashable : Any]?) {
                
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            AppsFlyerLib.shared().logEvent(eventName, withValues: data)
            
            self?.log(method: "trackEvent()", label: "eventName", labelValue: eventName, data: data)
        }
    }
    
    func handleOpenUrl(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
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
            if let customData = AppsFlyerLib.shared().customData {
                print("  customData: \(customData)")
            }
        }
    }
}

// MARK: - MobileContentAnalyticsSystem

extension AppsFlyer: MobileContentAnalyticsSystem {
    func trackAction(action: String, data: [AnyHashable : Any]?) {
        trackEvent(eventName: action, data: data)
    }
}
