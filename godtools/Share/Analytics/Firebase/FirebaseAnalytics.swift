//
//  FirebaseAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import TheKeyOAuthSwift
import GTMAppAuth

class FirebaseAnalytics: NSObject, FirebaseAnalyticsType {
    private let keyAuthClient: TheKeyOAuthClient
    private let languageSettingsService: LanguageSettingsService
    private let loggingEnabled: Bool
    
    private var previousTrackedScreenName: String = ""
    private var isConfigured: Bool = false
    
    required init(keyAuthClient: TheKeyOAuthClient, languageSettingsService: LanguageSettingsService, loggingEnabled: Bool) {
        self.keyAuthClient = keyAuthClient
        self.languageSettingsService = languageSettingsService
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        keyAuthClient.addStateChangeDelegate(delegate: self)
    }
    
    func configure() {
        
        if isConfigured {
            return
        }
                
        keyAuthClient.addStateChangeDelegate(delegate: self)
        
        isConfigured = true
                
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    //MARK: - Public
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String) {
        assertFailureIfNotConfigured()
        
        let previousScreenName: String = self.previousTrackedScreenName
        
        previousTrackedScreenName = screenName
        
        createDefaultPropertiesOnConcurrentQueue(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: previousScreenName) { [weak self] (defaultProperties: FirebaseAnalyticsProperties) in
        
            let data: [String: Any] = JsonServices().encode(object: defaultProperties)
                       
            Analytics.logEvent(AnalyticsEventScreenView, parameters: data)
            
            self?.log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: data)
        }
    }
    
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]?) {
        assertFailureIfNotConfigured()

        let modifiedActionName = actionName.replacingOccurrences(of: "(-|\\.|\\ )", with: "_", options: .regularExpression)
        
        let actionData: [String: Any]? = data as? [String: Any] ?? nil
        
        createDefaultPropertiesOnConcurrentQueue(screenName: screenName, siteSection: nil, siteSubSection: nil, previousScreenName: previousTrackedScreenName) { [weak self] (defaultProperties: FirebaseAnalyticsProperties) in
            
            var trackingData: [String: Any] = JsonServices().encode(object: defaultProperties)
            
            if let actionData = actionData {
                for (key, value) in actionData {
                    trackingData[key] = value
                }
            }
            
            Analytics.logEvent(modifiedActionName, parameters: trackingData)
                        
            self?.log(method: "trackAction()", label: "actionName", labelValue: modifiedActionName, data: trackingData)
        }
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
        assertFailureIfNotConfigured()
        
        createDefaultPropertiesOnConcurrentQueue(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: previousTrackedScreenName) { [weak self] (defaultProperties: FirebaseAnalyticsProperties) in
            
            var properties = defaultProperties
            
            properties.exitLink = url.absoluteString
            
            let actionName = AdobeAnalyticsConstants.Values.exitLink.replacingOccurrences(of: "(-|\\.|\\ )", with: "_", options: .regularExpression)
            
            let data: [String: Any] = JsonServices().encode(object: properties)
            
            Analytics.logEvent(actionName, parameters: data)
            
            self?.log(method: "trackExitLink()", label: actionName, labelValue: actionName, data: data)
        }
    }
    
    func fetchAttributesThenSetUserId() {
        assertFailureIfNotConfigured()
        
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()

        if isLoggedIn {
            keyAuthClient.fetchAttributes() { [weak self] (_, _) in
                self?.setUserId()
            }
        } else {
            setUserId()
        }
    }
    
    //MARK: - Private
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("AdobeAnalytics has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    private func setUserId() {
        assertFailureIfNotConfigured()
               
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
           
        let grMasterPersonID = isLoggedIn ? keyAuthClient.grMasterPersonId : nil
        let ssoguid = isLoggedIn ? keyAuthClient.guid : nil

        let userId = grMasterPersonID ?? ssoguid
        
        Analytics.setUserID(userId)
    }
    
    private func createDefaultPropertiesOnConcurrentQueue(screenName: String?, siteSection: String?, siteSubSection: String?, previousScreenName: String?, complete: @escaping ((_ properties: FirebaseAnalyticsProperties) -> Void)) {
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
        
        let appName: String = self.appName
        let contentLanguage: String? = languageSettingsService.primaryLanguage.value?.code
        let contentLanguageSecondary: String? = languageSettingsService.parallelLanguage.value?.code
        let grMasterPersonID: String? = keyAuthClient.isAuthenticated() ? keyAuthClient.grMasterPersonId : nil
        let loggedInStatus: String = self.loggedInStatus
        let ssoguid: String? = isLoggedIn ? keyAuthClient.guid : nil
                
        DispatchQueue.global().async { [] in
            let defaultProperties = FirebaseAnalyticsProperties(
                appName: appName,
                contentLanguage: contentLanguage,
                contentLanguageSecondary: contentLanguageSecondary,
                grMasterPersonID: grMasterPersonID,
                loggedInStatus: loggedInStatus,
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
            print("\nFirebaseAnalytics \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
            if let data = data {
                print("  data: \(data)")
            }
        }
    }
}

// MARK: - OIDAuthStateChangeDelegate

extension FirebaseAnalytics: OIDAuthStateChangeDelegate {
    func didChange(_ state: OIDAuthState) {
        fetchAttributesThenSetUserId()
    }
}

// MARK: - MobileContentAnalyticsSystem

extension FirebaseAnalytics: MobileContentAnalyticsSystem {
    func trackAction(action: String, data: [AnyHashable : Any]?) {
        trackAction(screenName: nil, actionName: action, data: data)
    }
}
