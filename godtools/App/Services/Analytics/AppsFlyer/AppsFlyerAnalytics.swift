//
//  AppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppsFlyerAnalytics: NSObject, AppsFlyerAnalyticsType {
    
    private let serialQueue: DispatchQueue = DispatchQueue(label: "appsflyer.serial.queue")
    private let loggingEnabled: Bool
    
    private var appsFlyer: AppsFlyerType?
    
    private var isConfigured: Bool = false
    
    required init(loggingEnabled: Bool) {
        
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    func configure(appsFlyer: AppsFlyerType, adobeAnalytics: AdobeAnalyticsType) {
        
        if isConfigured {
            return
        }
        
        self.appsFlyer = appsFlyer
         
        appsFlyer.setCustomAnalyticsData(data: ["marketingCloudID": adobeAnalytics.visitorMarketingCloudID])
                        
            
        isConfigured = true
        
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    func trackEvent(eventName: String, data: [String: Any]?) {
                
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            self?.appsFlyer?.logEvent(eventName: eventName, data: data)
            self?.log(method: "trackEvent()", label: "eventName", labelValue: eventName, data: data)
        }
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AppsFlyer has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    private func log(method: String, label: String?, labelValue: String?, data: [String: Any]?) {
        
        if loggingEnabled {
            print("\nAppsFlyer \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
            if let data = data {
                print("  data: \(data)")
            }
            if let customData = appsFlyer?.getCustomAnalyticsData() {
                print("  customData: \(customData)")
            }
        }
    }
}

// MARK: - MobileContentAnalyticsSystem

extension AppsFlyerAnalytics: MobileContentAnalyticsSystem {
    func trackAction(action: String, data: [String: Any]?) {
        trackEvent(eventName: action, data: data)
    }
}
