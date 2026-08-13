//
//  FirebaseAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseCore

actor FirebaseAnalytics: FirebaseAnalyticsInterface {
    
    private let isDebug: Bool
    private let loggingEnabled: Bool
    
    private var previousTrackedScreenName: String = ""
    private var isConfigured: Bool = false
    
    init(isDebug: Bool, loggingEnabled: Bool) {
        
        self.isDebug = isDebug
        self.loggingEnabled = loggingEnabled
    }
    
    func configure() {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        let loggerLevel: FirebaseLoggerLevel = !loggingEnabled ? .min : .max
        
        FirebaseCore.FirebaseConfiguration.shared.setLoggerLevel(loggerLevel)
                     
        setUserProperty(
            key: AnalyticsConstants.Keys.debug,
            value: isDebug ? AnalyticsConstants.Values.debugIsTrue : AnalyticsConstants.Values.debugIsFalse
        )
        
        log(method: "configure()", label: nil, labelValue: nil, data: nil)
    }
    
    func setLoggedInStateUserProperties(isLoggedIn: Bool, loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties?) {
        
        let userId: String? = loggedInUserProperties?.grMasterPersonId ?? loggedInUserProperties?.ssoguid
        
        Analytics.setUserID(isLoggedIn ? userId : nil)
        setUserProperty(key: AnalyticsConstants.UserProperties.loggedInStatus, value: isLoggedIn ? AnalyticsConstants.Values.isLoggedIn : AnalyticsConstants.Values.notLoggedIn)
        setUserProperty(key: AnalyticsConstants.UserProperties.loginProvider, value: isLoggedIn ? loggedInUserProperties?.loginProvider : nil)
        setUserProperty(key: AnalyticsConstants.Keys.grMasterPersonID, value: isLoggedIn ? loggedInUserProperties?.grMasterPersonId : nil)
        setUserProperty(key: AnalyticsConstants.Keys.ssoguid, value: isLoggedIn ? loggedInUserProperties?.ssoguid : nil)
    }
    
    func trackScreenView(properties: AnalyticsProperties) {

        internalTrackEvent(
            properties: properties,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsEventScreenView,
            data: nil
        )
        
        previousTrackedScreenName = properties.screenName
    }

    func trackAction(properties: AnalyticsProperties, actionName: String, data: [String: Any]?) {

        internalTrackEvent(
            properties: properties,
            previousScreenName: previousTrackedScreenName,
            eventName: actionName,
            data: data
        )
    }

    func trackExitLink(properties: AnalyticsProperties, url: String) {

        internalTrackEvent(
            properties: properties,
            previousScreenName: previousTrackedScreenName,
            eventName: AnalyticsConstants.Values.exitLink,
            data: [
                AnalyticsConstants.Keys.exitLink: url
            ]
        )
    }

    private func internalTrackEvent(properties: AnalyticsProperties, previousScreenName: String, eventName: String, data: [String: Any]?) {

        let baseParameters: [String: Any] = createBaseProperties(
            properties: properties,
            previousScreenName: previousScreenName
        )
        
        var parameters: [String: Any] = baseParameters
        
        if let data = data {
            for (key, value) in data where parameters[key] == nil {
                parameters[key] = value
            }
        }
        
        let transformedEventName: String = transformStringForFirebase(string: eventName).lowercased()
        let transformedData: [String: Any]? = transformDataForFirebase(data: parameters)
        
        Analytics.logEvent(transformedEventName, parameters: transformedData)
        
        log(method: "trackEvent()", label: "name", labelValue: transformedEventName, data: transformedData)
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
    
    private func createBaseProperties(properties: AnalyticsProperties, previousScreenName: String?) -> [String: String] {

        var baseProperties: [String: String] = [:]

        baseProperties[AnalyticsConstants.Keys.appName] = AnalyticsConstants.Values.godTools
        baseProperties[AnalyticsConstants.Keys.appLanguage] = properties.appLanguage
        baseProperties[AnalyticsConstants.Keys.contentLanguage] = properties.contentLanguage
        baseProperties[AnalyticsConstants.Keys.contentLanguageSecondary] = properties.secondaryContentLanguage
        baseProperties[AnalyticsConstants.Keys.previousScreenName] = previousScreenName
        baseProperties[AnalyticsConstants.Keys.screenNameFirebase] = properties.screenName
        baseProperties[AnalyticsConstants.Keys.siteSection] = properties.siteSection
        baseProperties[AnalyticsConstants.Keys.siteSubSection] = properties.siteSubSection

        return baseProperties
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
