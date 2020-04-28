//
//  PageViewedAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class PageViewedAnalytics {
    
    private let adobeAnalytics: AdobeAnalyticsType
    private let appsFlyer: AppsFlyerType
    private let firebaseAnalytics: FirebaseAnalyticsType
    
    required init(adobeAnalytics: AdobeAnalyticsType, appsFlyer: AppsFlyerType, firebaseAnalytics: FirebaseAnalyticsType) {
        
        self.adobeAnalytics = adobeAnalytics
        self.appsFlyer = appsFlyer
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackPageView(screenName: String, siteSection: String, siteSubSection: String) {
        
        adobeAnalytics.trackScreenView(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection)
        
        appsFlyer.trackEvent(eventName: screenName, data: nil)

        firebaseAnalytics.trackScreenView(screenName: screenName)
    }
}
