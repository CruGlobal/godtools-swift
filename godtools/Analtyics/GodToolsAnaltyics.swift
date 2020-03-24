//
//  GodToolsAnaltyics.swift
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import AdobeMobileSDK
import TheKeyOAuthSwift
import FirebaseAnalytics

class GodToolsAnaltyics {
    
    private let config: ConfigType
    private let appsFlyer: AppsFlyerType
    private let tracker: GAITracker
    private let loggingEnabled: Bool = false
    
    var previousScreenName = ""
    var adobeAnalyticsBackgroundQueue = DispatchQueue(label: "org.cru.godtools.adobeAnalytics", qos: .background)
        
    required init(config: ConfigType, appsFlyer: AppsFlyerType) {
        
        self.config = config
        self.appsFlyer = appsFlyer
        
        tracker = GAI.sharedInstance().tracker(withTrackingId: config.googleAnalyticsApiKey)
                                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordScreenView(notification:)),
                                               name: .screenViewNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordActionForADBMobile(notification:)),
                                               name: .actionTrackNotification,
                                               object: nil)
        
        recordAdwordsConversion()
        
        adobeAnalyticsBackgroundQueue.async { [weak self] () in
            self?.configureAdobeAnalytics()
        }
    }
    
    private func recordAdwordsConversion() {
        
        ACTConversionReporter.report(
            withConversionID: config.googleAdwordsConversionId,
            label: config.googleAdwordsLabel,
            value: "1.00",
            isRepeatable: false
        )
    }
    
    private func configureAdobeAnalytics() {
        loadAdobeAnalyticsConfigurationFile()
        var properties: [String: String] = [:]
        properties[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        properties[AdobeAnalyticsConstants.Keys.loggedInStatus] = getLoggedInStatus()
        properties[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        
        ADBMobile.collectLifecycleData(withAdditionalData: properties)
    }
    
    private func loadAdobeAnalyticsConfigurationFile() {
        var fileName = "ADBMobileConfig"
        
        #if DEBUG
            fileName = "ADBMobileConfig_debug"
        #endif
        
        let filePath = Bundle.main.path(forResource: fileName, ofType: "json")
        ADBMobile.overrideConfigPath(filePath)
    }
    
    @objc private func recordScreenView(notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let screenName = userInfo[GTConstants.kAnalyticsScreenNameKey] as? String else {
            return
        }
        let siteSection = userInfo[AdobeAnalyticsConstants.Keys.siteSection] as? String ?? ""
        let siteSubSection = userInfo[AdobeAnalyticsConstants.Keys.siteSubSection] as? String ?? ""
        
        recordScreenView(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection
        )
    }
    
    func recordScreenView(screenName: String, siteSection: String, siteSubSection: String) {
        
        tracker.set(kGAIScreenName, value: screenName)
        
        appsFlyer.trackEvent(eventName: screenName, data: nil)

        guard let screenViewInfo = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable : Any] else {
            return
        }
        
        tracker.send(screenViewInfo)
        
        adobeAnalyticsBackgroundQueue.async { [unowned self] () in
            self.recordScreenViewInAdobe(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection)
        }

        // Record screen view for Firebase Analytics
        DispatchQueue.main.async {
            Analytics.setScreenName(screenName, screenClass: nil)
        }
    }
    
    @objc private func recordActionForADBMobile(notification: Notification) {
                
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        guard let actionName = userInfo["action"] as? String else {
            return
        }
        
        recordActionForADBMobile(screenName: nil, actionName: actionName, data: userInfo)
    }
    
    func recordActionForADBMobile(screenName: String?, actionName: String, data: [String: Any]) {
        
        var mutableData: [String: Any] = data
        
        if let screenName = screenName {
            mutableData[AdobeAnalyticsConstants.Keys.screenName] = screenName
        }
        
        mutableData[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        mutableData[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        
        if TheKeyOAuthClient.shared.isAuthenticated(), let guid = TheKeyOAuthClient.shared.guid {
            mutableData[AdobeAnalyticsConstants.Keys.ssoguid] = guid
        }
        if TheKeyOAuthClient.shared.isAuthenticated(), let grMasterPersonId = TheKeyOAuthClient.shared.grMasterPersonId {
            mutableData[AdobeAnalyticsConstants.Keys.grMasterPersonID] = grMasterPersonId
        }
            
        mutableData.removeValue(forKey: "action")
                
        if loggingEnabled {
            print("\nTracking Adobe Analytics Action")
            print("  actionName: \(actionName)")
            print("  data: \(mutableData)\n")
        }
        
        adobeAnalyticsBackgroundQueue.async {
            ADBMobile.trackAction(actionName, data: mutableData)
        }
    }
    
    func recordExitLinkAction(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
        
        var properties: [String: Any] = getDefaultAnalyticsProperties(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection
        )
        
        properties.updateValue(url.absoluteString, forKey: AdobeAnalyticsConstants.Keys.exitAction)
        
        recordActionForADBMobile(
            screenName: screenName,
            actionName: AdobeAnalyticsConstants.Values.exitLink,
            data: properties
        )
    }
    
    private func recordScreenViewInAdobe(screenName: String, siteSection: String, siteSubSection: String) {
        
        let properties: [String: Any] = getDefaultAnalyticsProperties(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection
        )
                
        if loggingEnabled {
            print("\nTracking Adobe Analytics Screen View")
            print("  screenName: \(screenName)")
            print("  data: \(properties)\n")
        }
        
        previousScreenName = screenName
        
        ADBMobile.trackState(screenName, data: properties)
       // debugPrint("\(properties.debugDescription)")
    }
    
    private func getDefaultAnalyticsProperties(screenName: String, siteSection: String, siteSubSection: String) -> [String: Any] {
        
        var properties: [String: Any] = [:]
        
        let primaryLanguageCode = UserDefaults.standard.string(forKey: "kPrimaryLanguageCode") ?? ""
        let parallelLanguageCode = UserDefaults.standard.string(forKey: "kParallelLanguageCode") ?? ""
        
        properties[AdobeAnalyticsConstants.Keys.screenName] = screenName
        properties[AdobeAnalyticsConstants.Keys.previousScreenName] = previousScreenName
        properties[AdobeAnalyticsConstants.Keys.siteSection] = siteSection
        properties[AdobeAnalyticsConstants.Keys.siteSubSection] = siteSubSection
        properties[AdobeAnalyticsConstants.Keys.contentLanguage] = primaryLanguageCode
        properties[AdobeAnalyticsConstants.Keys.contentLanguageSecondary] = parallelLanguageCode
        properties[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        properties[AdobeAnalyticsConstants.Keys.loggedInStatus] = getLoggedInStatus()
        properties[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        
        if TheKeyOAuthClient.shared.isAuthenticated(), let guid = TheKeyOAuthClient.shared.guid {
            properties[AdobeAnalyticsConstants.Keys.ssoguid] = guid
        }
        if TheKeyOAuthClient.shared.isAuthenticated(), let grMasterPersonId = TheKeyOAuthClient.shared.grMasterPersonId {
            properties[AdobeAnalyticsConstants.Keys.grMasterPersonID] = grMasterPersonId
        }
        
        return properties
    }
    
    private func getLoggedInStatus() -> String {
        let client = TheKeyOAuthClient.shared
        if client.isAuthenticated() {
            return AdobeAnalyticsConstants.Values.isLoggedIn
        } else {
            return AdobeAnalyticsConstants.Values.notLoggedIn
        }
    }
    
}
