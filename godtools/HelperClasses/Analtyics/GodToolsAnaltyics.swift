//
//  GodToolsAnaltyics.swift
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class GodToolsAnaltyics {
                
    private let analytics: AnalyticsContainer
    
    required init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
                                        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordScreenView(notification:)),
                                               name: .screenViewNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordActionForADBMobile(notification:)),
                                               name: .actionTrackNotification,
                                               object: nil)
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
                        
        analytics.pageViewedAnalytics.trackPageView(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection)
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
        
        analytics.trackActionAnalytics.trackAction(screenName: screenName, actionName: actionName, data: data)
    }
}
