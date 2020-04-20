//
//  GodToolsAnaltyics.swift
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class GodToolsAnaltyics {
    
    private let config: ConfigType
    private let adobeAnalytics: AdobeAnalyticsType
    private let appsFlyer: AppsFlyerType
    private let firebaseAnalytics: FirebaseAnalyticsType
    
    var previousScreenName = ""
        
    required init(config: ConfigType, adobeAnalytics: AdobeAnalyticsType, appsFlyer: AppsFlyerType, firebaseAnalytics: FirebaseAnalyticsType) {
        
        self.config = config
        self.adobeAnalytics = adobeAnalytics
        self.appsFlyer = appsFlyer
        self.firebaseAnalytics = firebaseAnalytics
                                        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordScreenView(notification:)),
                                               name: .screenViewNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordActionForADBMobile(notification:)),
                                               name: .actionTrackNotification,
                                               object: nil)
        
        recordAdwordsConversion()
    }
    
    private func recordAdwordsConversion() {
        
        ACTConversionReporter.report(
            withConversionID: config.googleAdwordsConversionId,
            label: config.googleAdwordsLabel,
            value: "1.00",
            isRepeatable: false
        )
    }
    
    @objc private func recordScreenView(notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let screenName = userInfo[GTConstants.kAnalyticsScreenNameKey] as? String else {
            return
        }
        let siteSection = userInfo[AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue] as? String ?? ""
        let siteSubSection = userInfo[AdobeAnalyticsProperties.CodingKeys.siteSubSection.rawValue] as? String ?? ""
        
        recordScreenView(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection
        )
    }
    
    func recordScreenView(screenName: String, siteSection: String, siteSubSection: String) {
                
        adobeAnalytics.trackScreenView(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection)
        
        appsFlyer.trackEvent(eventName: screenName, data: nil)

        firebaseAnalytics.trackScreenView(screenName: screenName)
    }
    
    @objc private func recordActionForADBMobile(notification: Notification) {
                
        guard var userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        guard let actionName = userInfo["action"] as? String else {
            return
        }
        
        userInfo.removeValue(forKey: "action")
        
        recordActionForADBMobile(screenName: nil, actionName: actionName, data: userInfo)
    }
    
    func recordActionForADBMobile(screenName: String?, actionName: String, data: [String: Any]) {
        
        adobeAnalytics.trackAction(screenName: screenName, actionName: actionName, data: data)
    }
    
    func recordExitLinkAction(screenName: String, siteSection: String, siteSubSection: String, url: URL) {
        
        adobeAnalytics.trackExitLink(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            url: url
        )
    }
}
