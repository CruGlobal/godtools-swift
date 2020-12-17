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
    
    // TODO: We will REMOVE this once firebase is included in the xml and no longer tied to adobe from the xml. ~Levi
    private let firebaseAnalyticsSystem: MobileContentAnalyticsSystem
    
    required init(analytics: AnalyticsContainer) {
           
        // TODO: We will need to ADD this back in once firebase is included in the xml and no longer tied to adobe from the xml. ~Levi
        /*
        let analyticsSystems = [
            "adobe": analytics.adobeAnalytics,
            "appsflyer": analytics.appsFlyer,
            "firebase": analytics.firebaseAnalytics,
            "snowplow": analytics.snowplowAnalytics
        ]*/
        
        // TODO: We will REMOVE this once firebase is included in the xml and no longer tied to adobe from the xml. ~Levi
        let analyticsSystems = [
            "adobe": analytics.adobeAnalytics,
            "appsflyer": analytics.appsFlyer,
            "snowplow": analytics.snowplowAnalytics
        ]
        
        self.analyticsSystems = analyticsSystems
        self.firebaseAnalyticsSystem = analytics.firebaseAnalytics
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
             
            if let analyticsSystem = analyticsSystems[system] {
                analyticsSystem.trackAction(action: action, data: data)
            }
            
            // TODO: We will REMOVE this once firebase is included in the xml and no longer tied to adobe from the xml. ~Levi
            if system == "adobe" {
                firebaseAnalyticsSystem.trackAction(action: action, data: data)
            }
         }
    }
}
