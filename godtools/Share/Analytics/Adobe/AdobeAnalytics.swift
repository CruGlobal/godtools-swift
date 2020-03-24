//
//  AdobeAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import AdobeMobileSDK
import TheKeyOAuthSwift

class AdobeAnalytics: AdobeAnalyticsType {
    
    private let config: ConfigType
    private let keyAuthClient: TheKeyOAuthClient
    private let loggingEnabled: Bool
    
    private var previousTrackedScreenName: String = ""
    private var isConfigured: Bool = false
    
    required init(config: ConfigType, keyAuthClient: TheKeyOAuthClient, loggingEnabled: Bool) {
        
        self.config = config
        self.keyAuthClient = keyAuthClient
        self.loggingEnabled = loggingEnabled
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AdobeAnalytics has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    var visitorMarketingCloudID: String {
        assertFailureIfNotConfigured()
        if let visitorMarketingCloudID = ADBMobile.visitorMarketingCloudID() {
            return visitorMarketingCloudID
        }
        else {
            assertionFailure("AdobeAnalytics visitorMarketingCloudID is nil.  Make sure the Adobe SDK was configured properly.  Returning an empty string instead.")
            return ""
        }
    }
    
    func configure() {
        if isConfigured {
            return
        }
        isConfigured = true
        
        ADBMobile.overrideConfigPath(
            Bundle.main.path(
                forResource: config.isDebug ? "ADBMobileConfig_debug" : "ADBMobileConfig",
                ofType: "json"
        ))
        
        let lifeCycleData: AdobeAnalyticsProperties = AdobeAnalyticsProperties(
            appName: appName,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            exitLink: nil,
            grMasterPersonID: nil,
            loggedInStatus: loggedInStatus,
            marketingCloudID: visitorMarketingCloudID,
            previousScreenName: nil,
            screenName: nil,
            siteSection: nil,
            siteSubSection: nil,
            ssoguid: nil
        )
        
        ADBMobile.collectLifecycleData(withAdditionalData: JsonServices().encode(object: lifeCycleData))
    }
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String) {
        
        assertFailureIfNotConfigured()
        
        let defaultProperties: AdobeAnalyticsProperties = createDefaultProperties(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection
        )
        
        let data: [AnyHashable: Any] = JsonServices().encode(object: defaultProperties)
        
        if loggingEnabled {
            print("\nAdobe Analytics - Track Screen View")
            print("  screenName: \(screenName)")
            print("  data: \(data)")
        }
        
        ADBMobile.trackState(screenName, data: data)
        
        previousTrackedScreenName = screenName
    }
    
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]) {
        
        assertFailureIfNotConfigured()
        
        let properties: AdobeAnalyticsProperties = createDefaultProperties(
            screenName: screenName,
            siteSection: nil,
            siteSubSection: nil
        )
        
        var trackingData: [AnyHashable: Any] = JsonServices().encode(object: properties)
        
        for (key, value) in data {
            trackingData[key] = value
        }
        
        if loggingEnabled {
            print("\nAdobe Analytics - Track Action")
            print("  actionName: \(actionName)")
            print("  data: \(trackingData)")
        }
        
        ADBMobile.trackAction(actionName, data: trackingData)
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
              
        assertFailureIfNotConfigured()
        
        var properties: AdobeAnalyticsProperties = createDefaultProperties(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection
        )
        
        properties.exitLink = url.absoluteString
        
        let actionName: String = "Exit Link Engaged"
        
        let data: [AnyHashable: Any] = JsonServices().encode(object: properties)
                
        if loggingEnabled {
            print("\nAdobe Analytics - Track Exit Link Action")
            print("  actionName: \(actionName)")
            print("  data: \(data)")
        }
        
        ADBMobile.trackAction(actionName, data: data)
    }
    
    private func createDefaultProperties(screenName: String?, siteSection: String?, siteSubSection: String?) -> AdobeAnalyticsProperties {
        
        let defaultProperties = AdobeAnalyticsProperties(
            appName: appName,
            contentLanguage: UserDefaults.standard.string(forKey: "kPrimaryLanguageCode"),
            contentLanguageSecondary: UserDefaults.standard.string(forKey: "kParallelLanguageCode"),
            grMasterPersonID: keyAuthClient.isAuthenticated() ? keyAuthClient.grMasterPersonId : nil,
            loggedInStatus: loggedInStatus,
            marketingCloudID: ADBMobile.visitorMarketingCloudID(),
            previousScreenName: previousTrackedScreenName,
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            ssoguid: keyAuthClient.isAuthenticated() ? keyAuthClient.guid : nil
        )
        
        return defaultProperties
    }
    
    private var appName: String {
        return AdobeAnalyticsConstants.Values.godTools
    }
    
    private var loggedInStatus: String {
        return keyAuthClient.isAuthenticated() ? AdobeAnalyticsConstants.Values.isLoggedIn : AdobeAnalyticsConstants.Values.notLoggedIn
    }
}
