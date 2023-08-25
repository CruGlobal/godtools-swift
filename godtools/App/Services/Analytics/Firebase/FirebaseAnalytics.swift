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
import FirebaseCore

class FirebaseAnalytics {
    
    private let appBuild: AppBuild
    private let loggingEnabled: Bool
    
    private var previousTrackedScreenName: String = ""
    private var isConfigured: Bool = false
    
    init(appBuild: AppBuild, loggingEnabled: Bool) {
        
        self.appBuild = appBuild
        self.loggingEnabled = loggingEnabled
    }
    
    func configure() {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        if !loggingEnabled {
            FirebaseCore.FirebaseConfiguration.shared.setLoggerLevel(.min)
        }
        
        // gai
        if let gai = GAI.sharedInstance() {
            if appBuild.configuration == .analyticsLogging {
                gai.dispatchInterval = 1
            }
            
            gai.logger.logLevel = loggingEnabled ? .verbose : .none
        }
                        
        setUserProperty(
            key: AnalyticsConstants.Keys.debug,
            value: appBuild.isDebug ? AnalyticsConstants.Values.debugIsTrue : AnalyticsConstants.Values.debugIsFalse
        )
        
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    func setLoggedInStateUserProperties(isLoggedIn: Bool, loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties?) {
        assertFailureIfNotConfigured()
        
        let userId: String? = loggedInUserProperties?.grMasterPersonId ?? loggedInUserProperties?.ssoguid
        
        Analytics.setUserID(isLoggedIn ? userId : nil)
        setUserProperty(key: AnalyticsConstants.Keys.loggedInStatus, value: isLoggedIn ? AnalyticsConstants.Values.isLoggedIn : AnalyticsConstants.Values.notLoggedIn)
        setUserProperty(key: AnalyticsConstants.Keys.grMasterPersonID, value: isLoggedIn ? loggedInUserProperties?.grMasterPersonId : nil)
        setUserProperty(key: AnalyticsConstants.Keys.ssoguid, value: isLoggedIn ? loggedInUserProperties?.ssoguid : nil)
    }
    
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, secondaryContentLanguage: String?) {
        
        internalTrackEvent(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: contentLanguage,
            secondaryContentLanguage: secondaryContentLanguage,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsEventScreenView,
            data: nil
        )
        previousTrackedScreenName = screenName
    }
    
    func trackAction(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, secondaryContentLanguage: String?, actionName: String, data: [String : Any]?) {
        
        internalTrackEvent(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: contentLanguage,
            secondaryContentLanguage: secondaryContentLanguage,
            previousScreenName: previousTrackedScreenName,
            eventName: actionName,
            data: data
        )
    }
    
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, secondaryContentLanguage: String?, url: String) {
        
        internalTrackEvent(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: contentLanguage,
            secondaryContentLanguage: secondaryContentLanguage,
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
    
    private func internalTrackEvent(screenName: String?, siteSection: String?, siteSubSection: String?, contentLanguage: String?, secondaryContentLanguage: String?, previousScreenName: String, eventName: String, data: [String: Any]?) {
        
        assertFailureIfNotConfigured()
        
        DispatchQueue.global().async { [weak self] in
            
            guard let firebaseAnalytics = self else {
                return
            }
            
            let baseParameters: [String: Any] = firebaseAnalytics.createBaseProperties(
                screenName: screenName,
                siteSection: siteSection,
                siteSubSection: siteSubSection,
                contentLanguage: contentLanguage,
                secondaryContentLanguage: secondaryContentLanguage,
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
    
    private func setUserProperty(key: String, value: String?) {
        
        Analytics.setUserProperty(
            value,
            forName: transformStringForFirebase(string: key)
        )
    }
    
    private func createBaseProperties(screenName: String?, siteSection: String?, siteSubSection: String?, contentLanguage: String?, secondaryContentLanguage: String?, previousScreenName: String?) -> [String: String] {
        assertFailureIfNotConfigured()
        
        var properties: [String: String] = [:]
                
        properties[AnalyticsConstants.Keys.appName] = AnalyticsConstants.Values.godTools
        properties[AnalyticsConstants.Keys.contentLanguage] = contentLanguage
        properties[AnalyticsConstants.Keys.contentLanguageSecondary] = secondaryContentLanguage
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
