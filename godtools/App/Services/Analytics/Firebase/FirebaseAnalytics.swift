//
//  FirebaseAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import GoogleAnalytics

class FirebaseAnalytics: NSObject {
    
    private let config: AppConfig
    private let userAuthentication: UserAuthenticationType
    private let languageSettingsService: LanguageSettingsService
    private let loggingEnabled: Bool
    
    private var previousTrackedScreenName: String = ""
    private var isConfigured: Bool = false
    
    required init(config: AppConfig, userAuthentication: UserAuthenticationType, languageSettingsService: LanguageSettingsService, loggingEnabled: Bool) {
        
        self.config = config
        self.userAuthentication = userAuthentication
        self.languageSettingsService = languageSettingsService
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        userAuthentication.authenticatedUser.removeObserver(self)
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
                        
        setUserProperty(
            key: AnalyticsConstants.Keys.debug,
            value: config.isDebug ? AnalyticsConstants.Values.debugIsTrue : AnalyticsConstants.Values.debugIsFalse
        )
        
        userAuthentication.authenticatedUser.addObserver(self) { [weak self] (authUser: AuthUserModelType?) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.setUserProperties(authUser: authUser, isLoggedIn: weakSelf.userAuthentication.isAuthenticated)
        }
        
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String) {
        
        internalTrackEvent(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsEventScreenView,
            data: nil
        )
        previousTrackedScreenName = screenName
    }
    
    func trackAction(screenName: String, siteSection: String, siteSubSection: String, actionName: String, data: [String : Any]?) {
        
        internalTrackEvent(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            previousScreenName: previousTrackedScreenName,
            eventName: actionName,
            data: data
        )
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: String) {
        
        internalTrackEvent(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsConstants.Values.exitLink,
            data: [
                AnalyticsConstants.Keys.exitLink: url
            ]
        )
    }
        
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
            
            let transformedEventName: String = firebaseAnalytics.transformStringForFirebase(string: eventName).lowercased()
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
            let transformedKey: String = transformStringForFirebase(string: key).lowercased()
            let transformedValue: Any = value
            transformedData[transformedKey] = transformedValue
        }
        
        return transformedData
    }
    
    private func transformStringForFirebase(string: String) -> String {
        return string.replacingOccurrences(of: "(-|\\.|\\ )", with: "_", options: .regularExpression).lowercased()
    }
    
    private func setUserProperties(authUser: AuthUserModelType?, isLoggedIn: Bool) {
        assertFailureIfNotConfigured()
                                  
        let grMasterPersonID: String? = authUser?.grMasterPersonId
        let ssoguid: String? = authUser?.ssoGuid
        let userId: String? = grMasterPersonID ?? ssoguid
        
        Analytics.setUserID(userId)
        setUserProperty(key: AnalyticsConstants.Keys.loggedInStatus, value: isLoggedIn ? AnalyticsConstants.Values.isLoggedIn : AnalyticsConstants.Values.notLoggedIn)
        setUserProperty(key: AnalyticsConstants.Keys.grMasterPersonID, value: grMasterPersonID)
        setUserProperty(key: AnalyticsConstants.Keys.ssoguid, value: ssoguid)
    }
    
    private func setUserProperty(key: String, value: String?) {
        
        Analytics.setUserProperty(
            value,
            forName: transformStringForFirebase(string: key)
        )
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
