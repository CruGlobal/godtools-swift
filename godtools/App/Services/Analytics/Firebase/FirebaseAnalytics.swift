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

class FirebaseAnalytics: NSObject, FirebaseAnalyticsType, MobileContentAnalyticsSystem {
    
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
        
        super.init()
    }
    
    func configure() {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        // gai
        if let gai = GAI.sharedInstance() {
            if config.build == .analyticsLogging {
                gai.dispatchInterval = 1
            }
            
            gai.logger.logLevel = loggingEnabled ? .verbose : .none
        }
        
        keyAuthClient.addStateChangeDelegate(delegate: self)
        
        if config.isDebug {
            Analytics.setUserProperty(AnalyticsConstants.Values.debugIsTrue, forName: transformStringForFirebase(AnalyticsConstants.Keys.debug))
        }
        else {
            Analytics.setUserProperty(AnalyticsConstants.Values.debugIsFalse, forName: transformStringForFirebase(AnalyticsConstants.Keys.debug))
        }
        
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    //MARK: - Public
    
    func trackScreenView(trackScreen: TrackScreenModel) {
        internalTrackEvent(
            screenName: trackScreen.screenName,
            siteSection: trackScreen.siteSection,
            siteSubSection: trackScreen.siteSubSection,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsEventScreenView,
            data: nil
        )
        previousTrackedScreenName = trackScreen.screenName
    }

    func trackAction(trackAction: TrackActionModel) {
        internalTrackEvent(
            screenName: trackAction.screenName,
            siteSection: trackAction.siteSection,
            siteSubSection: trackAction.siteSubSection,
            previousScreenName: previousTrackedScreenName,
            eventName: trackAction.actionName,
            data: trackAction.data
        )
    }
    
    func trackExitLink(exitLink: ExitLinkModel) {
        internalTrackEvent(
            screenName: exitLink.screenName,
            siteSection: exitLink.siteSection,
            siteSubSection: exitLink.siteSubSection,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsConstants.Values.exitLink,
            data: [
                AnalyticsConstants.Keys.exitLink: exitLink.url
            ]
        )
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
    
    private func internalTrackEvent(screenName: String?, siteSection: String?, siteSubSection: String?, previousScreenName: String, eventName: String, data: [String: Any]?) {
        
        assertFailureIfNotConfigured()
        
        DispatchQueue.global().async { [weak self] in
            
            guard let firebaseAnalytics = self else {
                return
            }
            
            let baseParameters: [String: Any] = firebaseAnalytics.createBaseProperties(
                screenName: screenName,
                siteSection: siteSection,
                siteSubSection: siteSubSection,
                previousScreenName: previousScreenName
            )
            
            var parameters: [String: Any] = baseParameters
            
            if let data = data {
                for (key, value) in data {
                    if parameters[key] == nil {
                        parameters[key] = value
                    }
                }
            }
            
            let transformedEventName: String = firebaseAnalytics.transformStringForFirebase(eventName).lowercased()
            let transformedData: [String: Any]? = firebaseAnalytics.transformDataForFirebase(data: parameters)
            
            Analytics.logEvent(transformedEventName, parameters: transformedData)
            
            firebaseAnalytics.log(method: "trackEvent()", label: "name", labelValue: transformedEventName, data: transformedData)
        }
    }
    
    private func transformDataForFirebase(data: [String: Any]?) -> [String: Any]? {
        guard let attributesData = data else {
            return nil
        }
        
        var transformedData: [String: Any] = Dictionary()
        
        for (key, value) in attributesData {
            let transformedKey: String = transformStringForFirebase(key).lowercased()
            let transformedValue: Any = value
            transformedData[transformedKey] = transformedValue
        }
        
        return transformedData
    }
    
    private func transformStringForFirebase(_ key: String) -> String {
        return key.replacingOccurrences(of: "(-|\\.|\\ )", with: "_", options: .regularExpression).lowercased()
    }
    
    private func setUserProperties() {
        assertFailureIfNotConfigured()
               
        let isLoggedIn: Bool = keyAuthClient.isAuthenticated()
        
        let loggedInStatus = isLoggedIn ? AnalyticsConstants.Values.isLoggedIn : AnalyticsConstants.Values.notLoggedIn
           
        let grMasterPersonID = isLoggedIn ? keyAuthClient.grMasterPersonId : nil
        let ssoguid = isLoggedIn ? keyAuthClient.guid : nil

        let userId = grMasterPersonID ?? ssoguid
        
        Analytics.setUserID(userId)
        Analytics.setUserProperty(loggedInStatus, forName: transformStringForFirebase(AnalyticsConstants.Keys.loggedInStatus))
        Analytics.setUserProperty(grMasterPersonID, forName: transformStringForFirebase(AnalyticsConstants.Keys.grMasterPersonID))
        Analytics.setUserProperty(ssoguid, forName: transformStringForFirebase(AnalyticsConstants.Keys.ssoguid))
    }
    
    private func createBaseProperties(screenName: String?, siteSection: String?, siteSubSection: String?, previousScreenName: String?) -> [String: String] {
        assertFailureIfNotConfigured()
        
        var properties: [String: String] = [:]
                
        properties[AnalyticsConstants.Keys.appName] = AnalyticsConstants.Values.godTools
        properties[AnalyticsConstants.Keys.contentLanguage] = languageSettingsService.primaryLanguage.value?.code
        properties[AnalyticsConstants.Keys.contentLanguageSecondary] = languageSettingsService.parallelLanguage.value?.code
        properties[AnalyticsConstants.Keys.previousScreenName] = previousScreenName
        properties[AnalyticsConstants.Keys.screenNameFirebase] = screenName
        properties[AnalyticsConstants.Keys.siteSection] = siteSection
        properties[AnalyticsConstants.Keys.siteSubSection] = siteSubSection
        
        return properties
    }
    
    private func log(method: String, label: String?, labelValue: String?, data: [String: Any]?) {
        
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
