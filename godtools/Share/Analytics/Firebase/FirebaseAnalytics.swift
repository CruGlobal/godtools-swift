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
        
        DispatchQueue.global().async { [weak self] in
            let parameters = self?.createBaseProperties(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: previousScreenName)
                    
            Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
            
            self?.log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: parameters)
        }
    }
    
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]?) {
        assertFailureIfNotConfigured()
        
        let modifiedActionName = prepPropertyForFirebase(key: actionName)

        DispatchQueue.global().async { [weak self] in
            
            let actionData: [String: Any]? = data as? [String: Any] ?? nil
            
            let baseParameters: [String: Any] = self?.createBaseProperties(screenName: screenName, siteSection: nil, siteSubSection: nil, previousScreenName: self?.previousTrackedScreenName) ?? [:]
            
            var parameters: [String: Any] = baseParameters
            
            if let actionData = actionData {
                for (key, value) in actionData {
                    parameters[key] = value
                }
            }
            
            Analytics.logEvent(modifiedActionName, parameters: parameters)
            
            self?.log(method: "trackAction()", label: "actionName", labelValue: modifiedActionName, data: parameters)
        }
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
        assertFailureIfNotConfigured()
        
        let actionName = prepPropertyForFirebase(key: AnalyticsConstants.Values.exitLink)
        
        DispatchQueue.global().async { [weak self] in
            let baseParameters: [String: Any] = self?.createBaseProperties(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: self?.previousTrackedScreenName) ?? [:]
              
            var parameters: [String: Any] = baseParameters
            
            parameters[AnalyticsConstants.Keys.exitLink] = url.absoluteString
                
            
            Analytics.logEvent(actionName, parameters: parameters)
                
            self?.log(method: "trackExitLink()", label: actionName, labelValue: actionName, data: parameters)
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
            assertionFailure("FirebaseAnalytics has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    private func prepPropertyForFirebase(key: String) -> String {
        return key.replacingOccurrences(of: "(-|\\.|\\ )", with: "_", options: .regularExpression)
    }
    
    private func setUserId() {
        assertFailureIfNotConfigured()
               
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
           
        let grMasterPersonID = isLoggedIn ? keyAuthClient.grMasterPersonId : nil
        let ssoguid = isLoggedIn ? keyAuthClient.guid : nil

        let userId = grMasterPersonID ?? ssoguid
        
        Analytics.setUserID(userId)
    }
    
    private func createBaseProperties(screenName: String?, siteSection: String?, siteSubSection: String?, previousScreenName: String?) -> [String: Any] {
        assertFailureIfNotConfigured()
        
        var properties: [String: Any] = [:]
        
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
        
        properties[AnalyticsConstants.Keys.appName] = AnalyticsConstants.Values.godTools
        properties[AnalyticsConstants.Keys.contentLanguage] = languageSettingsService.primaryLanguage.value?.code
        properties[AnalyticsConstants.Keys.contentLanguageSecondary] = languageSettingsService.parallelLanguage.value?.code
        properties[AnalyticsConstants.Keys.grMasterPersonID] = keyAuthClient.isAuthenticated() ? keyAuthClient.grMasterPersonId : nil
        properties[AnalyticsConstants.Keys.loggedInStatus] = isLoggedIn ? AnalyticsConstants.Values.isLoggedIn : AnalyticsConstants.Values.notLoggedIn
        properties[AnalyticsConstants.Keys.previousScreenName] = previousScreenName
        properties[AnalyticsConstants.Keys.screenName] = screenName
        properties[AnalyticsConstants.Keys.siteSection] = siteSection
        properties[AnalyticsConstants.Keys.siteSubSection] = siteSubSection
        properties[AnalyticsConstants.Keys.ssoguid] = isLoggedIn ? keyAuthClient.guid : nil
        
        return properties
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
