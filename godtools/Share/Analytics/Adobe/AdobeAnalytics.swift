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
import GTMAppAuth

class AdobeAnalytics: NSObject, AdobeAnalyticsType {
    private let config: ConfigType
    private let keyAuthClient: TheKeyOAuthClient
    private let languageSettingsService: LanguageSettingsService
    private let loggingEnabled: Bool
    
    private var previousTrackedScreenName: String = ""
    private var isConfigured: Bool = false
        
    required init(config: ConfigType, keyAuthClient: TheKeyOAuthClient, languageSettingsService: LanguageSettingsService, loggingEnabled: Bool) {
        
        self.config = config
        self.keyAuthClient = keyAuthClient
        self.languageSettingsService = languageSettingsService
        self.loggingEnabled = loggingEnabled
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AdobeAnalytics has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    // NOTE: When calling this field, call it from a non blocking UI thread.
    // From Adobe SDK: @note This method can cause a blocking network call and should not be used from a UI thread.
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
                
        ADBMobile.overrideConfigPath(
            Bundle.main.path(
                forResource: config.isDebug ? "ADBMobileConfig_debug" : "ADBMobileConfig",
                ofType: "json"
        ))
        
        isConfigured = true
                
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    func collectLifecycleData() {
                
        var lifecycleData = AdobeAnalyticsProperties()
        lifecycleData.appName = appName
        lifecycleData.loggedInStatus = loggedInStatus
        
        DispatchQueue.global().async { [weak self] in
            
            self?.assertFailureIfNotConfigured()
            
            lifecycleData.marketingCloudID = self?.visitorMarketingCloudID ?? ""
            
            ADBMobile.collectLifecycleData(withAdditionalData: JsonServices().encode(object: lifecycleData))
            
            self?.log(method: "collectLifecycleData()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String) {
        
        assertFailureIfNotConfigured()
        
        let previousScreenName: String = self.previousTrackedScreenName
        
        previousTrackedScreenName = screenName
                
        createDefaultProperties(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: previousScreenName) { [weak self] (defaultProperties: AdobeAnalyticsProperties) in
            
            let data: [AnyHashable: Any] = JsonServices().encode(object: defaultProperties)
            
            ADBMobile.trackState(screenName, data: data)
            
            self?.log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: data)
        }
    }
    
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]) {
        
        assertFailureIfNotConfigured()
        
        createDefaultProperties(screenName: screenName, siteSection: nil, siteSubSection: nil, previousScreenName: previousTrackedScreenName) { [weak self] (defaultProperties: AdobeAnalyticsProperties) in
            
            var trackingData: [AnyHashable: Any] = JsonServices().encode(object: defaultProperties)
            
            for (key, value) in data {
                trackingData[key] = value
            }
            
            ADBMobile.trackAction(actionName, data: trackingData)
            
            self?.log(method: "trackAction()", label: "actionName", labelValue: actionName, data: trackingData)
        }
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
           
        assertFailureIfNotConfigured()
        
        createDefaultProperties(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: previousTrackedScreenName) { [weak self] (defaultProperties: AdobeAnalyticsProperties) in
            
            var properties = defaultProperties
            
            properties.exitLink = url.absoluteString
            
            let actionName: String = "Exit Link Engaged"
            
            let data: [AnyHashable: Any] = JsonServices().encode(object: properties)
            
            ADBMobile.trackAction(actionName, data: data)
            
            self?.log(method: "trackExitLink()", label: actionName, labelValue: actionName, data: data)
        }
    }
    
    func syncVisitorId() {
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()

        let grMasterPersonID: String? = isLoggedIn ? keyAuthClient.grMasterPersonId : nil
        let ssoguid: String? = isLoggedIn ? keyAuthClient.guid : nil
        
        let visitorId: String? = grMasterPersonID ?? ssoguid ?? visitorMarketingCloudID
        
        let authState: ADBMobileVisitorAuthenticationState = ((grMasterPersonID ?? ssoguid) == nil) ? ADBMobileVisitorAuthenticationState.unknown : (isLoggedIn ? ADBMobileVisitorAuthenticationState.authenticated : ADBMobileVisitorAuthenticationState.loggedOut)

        ADBMobile.visitorSyncIdentifier(withType: "cru_visitor_id", identifier: visitorId, authenticationState: authState)
    }
    
    private func createDefaultProperties(screenName: String?, siteSection: String?, siteSubSection: String?, previousScreenName: String?, complete: @escaping ((_ properties: AdobeAnalyticsProperties) -> Void)) {
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
        
        let appName: String = self.appName
        let contentLanguage: String? = languageSettingsService.primaryLanguage.value?.code
        let contentLanguageSecondary: String? = languageSettingsService.parallelLanguage.value?.code
        let grMasterPersonID: String? = keyAuthClient.isAuthenticated() ? keyAuthClient.grMasterPersonId : nil
        let loggedInStatus: String = self.loggedInStatus
        let ssoguid: String? = isLoggedIn ? keyAuthClient.guid : nil
                
        DispatchQueue.global().async { [weak self] in
            
            let visitorMarketingCloudID: String? = self?.visitorMarketingCloudID
            
            let defaultProperties = AdobeAnalyticsProperties(
                appName: appName,
                contentLanguage: contentLanguage,
                contentLanguageSecondary: contentLanguageSecondary,
                grMasterPersonID: grMasterPersonID,
                loggedInStatus: loggedInStatus,
                marketingCloudID: visitorMarketingCloudID,
                previousScreenName: previousScreenName,
                screenName: screenName,
                siteSection: siteSection,
                siteSubSection: siteSubSection,
                ssoguid: ssoguid
            )
                        
            complete(defaultProperties)
        }
    }
    
    private var appName: String {
        return AdobeAnalyticsConstants.Values.godTools
    }
    
    private var loggedInStatus: String {
        return keyAuthClient.isAuthenticated() ? AdobeAnalyticsConstants.Values.isLoggedIn : AdobeAnalyticsConstants.Values.notLoggedIn
    }
    
    private func log(method: String, label: String?, labelValue: String?, data: [AnyHashable: Any]?) {
        
        if loggingEnabled {
            print("\nAdobeAnalytics \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
            if let data = data {
                print("  data: \(data)")
            }
        }
    }
}
