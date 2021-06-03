//
//  AppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppsFlyerAnalytics: NSObject, AppsFlyerAnalyticsType, MobileContentAnalyticsSystem {
    
    private let serialQueue: DispatchQueue = DispatchQueue(label: "appsflyer.serial.queue")
    private let loggingEnabled: Bool
    
    private var appsFlyer: AppsFlyerType
    
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false
    
    required init(appsFlyer: AppsFlyerType, loggingEnabled: Bool) {
        
        self.appsFlyer = appsFlyer
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    func configure(adobeAnalytics: AdobeAnalyticsType) {
            
        if isConfigured || isConfiguring {
            return
        }
        
        isConfiguring = true
        
        serialQueue.async { [weak self] in
                        
            self?.appsFlyer.appsFlyerLib.customData = ["marketingCloudID": adobeAnalytics.visitorMarketingCloudID]
            
            self?.isConfigured = true
            self?.isConfiguring = false
            
            self?.log(method: "configure()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    func trackAppLaunch() {
                    
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
        
            self?.appsFlyer.appsFlyerLib.start()
                        
            self?.log(method: "trackAppLaunch()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    func trackAction(trackAction: TrackActionModel) {
                
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            self?.appsFlyer.appsFlyerLib.logEvent(trackAction.actionName, withValues: trackAction.data)
            self?.log(method: "trackEvent()", label: "eventName", labelValue: trackAction.actionName, data: trackAction.data)
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
            if let customData = appsFlyer.appsFlyerLib.customData {
                print("  customData: \(customData)")
            }
        }
    }
}
