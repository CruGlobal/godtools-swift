//
//  MobileContentAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentAnalytics {
    
    private let analyticsSystems: [String: MobileContentAnalyticsSystem]
        
    required init(analytics: AnalyticsContainer) {
           
        let analyticsSystems = [
            "appsflyer": analytics.appsFlyerAnalytics,
            "firebase": analytics.firebaseAnalytics,
            "snowplow": analytics.snowplowAnalytics
        ]
 
        self.analyticsSystems = analyticsSystems
    }
    
    func trackEvents(events: AnalyticsEventsNode, page: MobileContentRendererPageModel) {
        
        let events: [AnalyticsEventNode] = events.children as? [AnalyticsEventNode] ?? []
        
        for event in events {
            trackEvent(event: event, page: page)
        }
    }
    
    func trackEvent(event: AnalyticsEventNode, page: MobileContentRendererPageModel) {
        
        guard let action = event.action, !action.isEmpty else {
            return
        }
        
        let attribute: AnalyticsAttributeNode? = event.children.first as? AnalyticsAttributeNode
        
         let data: [String: Any]?
         
         if let key = attribute?.key, let value = attribute?.value {
             data = [key: value]
         }
         else {
             data = nil
         }
         
         for system in event.systems {
             
            if let analyticsSystem = analyticsSystems[system] {
                
                let resource = page.resource.abbreviation
                let pageNumber = page.page
                let screenName = resource + "-" + String(pageNumber)
                
                analyticsSystem.trackAction(trackAction: TrackActionModel(screenName: screenName, actionName: action, siteSection: resource, siteSubSection: "", url: nil, data: data))
            }
         }
    }
}
