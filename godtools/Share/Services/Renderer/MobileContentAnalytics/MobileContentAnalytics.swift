//
//  MobileContentAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentAnalytics {
    
    private let analytics: AnalyticsContainer
    
    required init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
    }
    
    func trackEvents(events: AnalyticsEventsNode) {
        
        let events: [AnalyticsEventNode] = events.children as? [AnalyticsEventNode] ?? []
        
        for event in events {
            trackEvent(event: event)
        }
    }
    
    private func trackEvent(event: AnalyticsEventNode) {
        
        if let action = event.action, !action.isEmpty {
            
            let attribute: AnalyticsAttributeNode? = event.children.first as? AnalyticsAttributeNode
           
            let data: [AnyHashable: Any]?
            
            if let key = attribute?.key, let value = attribute?.value {
                data = [key: value]
            }
            else {
                data = nil
            }
            
            for system in event.systems {
                
                if system == "adobe" {
                    analytics.adobeAnalytics.trackAction(screenName: nil, actionName: action, data: data)
                }
            }
        }
    }
}
