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
            "adobe": analytics.adobeAnalytics,
            "appsflyer": analytics.appsFlyer,
            "firebase": analytics.firebaseAnalytics,
            "snowplow": analytics.snowplowAnalytics
        ]
        
        self.analyticsSystems = analyticsSystems
    }
    
    func trackEvents(events: AnalyticsEventsNode) {
        
        let events: [AnalyticsEventNode] = events.children as? [AnalyticsEventNode] ?? []
        
        for event in events {
            trackEvent(event: event)
        }
    }
    
    func trackEvent(event: AnalyticsEventNode) {
        
        guard let action = event.action, !action.isEmpty else {
            return
        }
        
        let attribute: AnalyticsAttributeNode? = event.children.first as? AnalyticsAttributeNode
        
         let data: [AnyHashable: Any]?
         
         if let key = attribute?.key, let value = attribute?.value {
             data = [key: value]
         }
         else {
             data = nil
         }
         
         for system in event.systems {
             
             analyticsSystems[system]?.trackAction(action: action, data: data)
         }
    }
}
