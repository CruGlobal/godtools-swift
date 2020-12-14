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
        
        #if DEBUG
            Analytics.setUserProperty(AnalyticsConstants.Values.debugIsTrue, forName: AnalyticsConstants.Keys.debug)
        #else
            Analytics.setUserProperty(AnalyticsConstants.Values.debugIsTrue, forName: AnalyticsConstants.Keys.debug)
        #endif
                
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    //MARK: - Public
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String) {
        assertFailureIfNotConfigured()
        
        let previousScreenName: String = self.previousTrackedScreenName
        
        previousTrackedScreenName = screenName
        
        DispatchQueue.global().async { [weak self] in
            guard let firebaseAnalytics = self else { return }
            
            let parameters = firebaseAnalytics.createBaseProperties(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: previousScreenName)
                    
            Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
            
            firebaseAnalytics.log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: parameters)
        }
    }
    
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable : Any]?) {
        assertFailureIfNotConfigured()

        DispatchQueue.global().async { [weak self] in
            guard let firebaseAnalytics = self else { return }
            
            let modifiedActionName = firebaseAnalytics.prepPropertyForFirebase(actionName) ?? ""
            
            let actionData: [String: Any]? = data as? [String: Any] ?? nil
            
            let baseParameters: [String: Any] = firebaseAnalytics.createBaseProperties(screenName: screenName, siteSection: nil, siteSubSection: nil, previousScreenName: self?.previousTrackedScreenName) ?? [:]
            
            var parameters: [String: Any] = baseParameters
            
            if let actionData = actionData {
                for (key, value) in actionData {
                    parameters[firebaseAnalytics.prepPropertyForFirebase(key) ?? key] = value
                }
            }
            
            Analytics.logEvent(modifiedActionName, parameters: parameters)
            
            firebaseAnalytics.log(method: "trackAction()", label: "actionName", labelValue: modifiedActionName, data: parameters)
        }
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
        assertFailureIfNotConfigured()
                
        DispatchQueue.global().async { [weak self] in
            guard let firebaseAnalytics = self else { return }
            
            let actionName = firebaseAnalytics.prepPropertyForFirebase(AnalyticsConstants.Values.exitLink) ?? AnalyticsConstants.Values.exitLink
            
            let baseParameters: [String: Any] = firebaseAnalytics.createBaseProperties(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, previousScreenName: firebaseAnalytics.previousTrackedScreenName) ?? [:]
              
            var parameters: [String: Any] = baseParameters
            
            parameters[firebaseAnalytics.prepPropertyForFirebase(AnalyticsConstants.Keys.exitLink) ?? AnalyticsConstants.Keys.exitLink] = url.absoluteString
                
            Analytics.logEvent(actionName, parameters: parameters)
                
            firebaseAnalytics.log(method: "trackExitLink()", label: actionName, labelValue: actionName, data: parameters)
        }
    }
    
    func fetchAttributesThenSetUserId() {
        assertFailureIfNotConfigured()
        
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()

        if isLoggedIn {
            keyAuthClient.fetchAttributes() { [weak self] (_, _) in
                guard let firebaseAnalytics = self else { return }
                
                firebaseAnalytics.setUserProperties()
            }
        } else {
            setUserProperties()
        }
    }
    
    //MARK: - Private
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("FirebaseAnalytics has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }
    
    private func prepPropertyForFirebase(_ key: String) -> String {
        return key.replacingOccurrences(of: "(-|\\.|\\ )", with: "_", options: .regularExpression)
    }
    
    private func setUserProperties() {
        assertFailureIfNotConfigured()
               
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
        
        let loggedInStatus = isLoggedIn ? AnalyticsConstants.Values.isLoggedIn : AnalyticsConstants.Values.notLoggedIn
           
        let grMasterPersonID = isLoggedIn ? keyAuthClient.grMasterPersonId : nil
        let ssoguid = isLoggedIn ? keyAuthClient.guid : nil

        let userId = grMasterPersonID ?? ssoguid
        
        Analytics.setUserID(userId)
        Analytics.setUserProperty(loggedInStatus, forName: prepPropertyForFirebase(AnalyticsConstants.Keys.loggedInStatus))
        Analytics.setUserProperty(grMasterPersonID, forName: prepPropertyForFirebase(AnalyticsConstants.Keys.grMasterPersonID))
        Analytics.setUserProperty(ssoguid, forName: prepPropertyForFirebase(AnalyticsConstants.Keys.ssoguid))
    }
    
    private func createBaseProperties(screenName: String?, siteSection: String?, siteSubSection: String?, previousScreenName: String?) -> [String: Any] {
        assertFailureIfNotConfigured()
        
        var properties: [String: Any] = [:]
                
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.appName)] = AnalyticsConstants.Values.godTools
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.contentLanguage)] = languageSettingsService.primaryLanguage.value?.code
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.contentLanguageSecondary)] = languageSettingsService.parallelLanguage.value?.code
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.previousScreenName)] = previousScreenName
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.screenName)] = screenName
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.siteSection)] = siteSection
        properties[prepPropertyForFirebase(AnalyticsConstants.Keys.siteSubSection)] = siteSubSection
        
        return properties
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
