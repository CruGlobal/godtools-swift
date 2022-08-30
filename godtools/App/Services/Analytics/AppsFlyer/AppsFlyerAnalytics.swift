//
//  AppsFlyer.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AppsFlyerAnalytics: NSObject {
    
    private let serialQueue: DispatchQueue = DispatchQueue(label: "appsflyer.serial.queue")
    private let loggingEnabled: Bool
    
    private var appsFlyer: AppsFlyer
    
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false
    
    required init(appsFlyer: AppsFlyer, loggingEnabled: Bool) {
        
        self.appsFlyer = appsFlyer
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    func configure() {
            
        if isConfigured || isConfiguring {
            return
        }
        
        isConfiguring = true
        
        serialQueue.async { [weak self] in
                        
            self?.appsFlyer.appsFlyerLib.customData = [:]
            
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
    
    func trackAction(actionName: String, data: [String : Any]?) {
                
        serialQueue.async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            self?.appsFlyer.appsFlyerLib.logEvent(actionName, withValues: data)
            self?.log(method: "trackEvent()", label: "eventName", labelValue: actionName, data: data)
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
