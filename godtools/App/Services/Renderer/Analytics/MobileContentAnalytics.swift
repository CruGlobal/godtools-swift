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
    
    // TODO: Remove AnalyticsEventNode and AnalyticsEventsNode and replace with AnalyticsEventModelType. ~Levi
    
    func trackEvents(events: AnalyticsEventsNode, page: MobileContentRendererPageModel) {
        
        let events: [AnalyticsEventNode] = events.analyticsEventNodes
        
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
                
                let resourceAbbreviation = page.resource.abbreviation
                let pageNumber = page.page
                let screenName = resourceAbbreviation + "-" + String(pageNumber)
                
                analyticsSystem.trackMobileContentAction(
                    screenName: screenName,
                    siteSection: resourceAbbreviation,
                    action: action,
                    data: data
                )
            }
         }
    }
    
    // TODO: Remove above two functions. ~Levi
    
    func trackEvents(events: [AnalyticsEventModelType], page: MobileContentRendererPageModel) {
        
        for event in events {
            trackEvent(event: event, page: page)
        }
    }
    
    private func trackEvent(event: AnalyticsEventModelType, page: MobileContentRendererPageModel) {
        
        guard let action = event.action, !action.isEmpty else {
            return
        }
        
        let attribute: AnalyticsAttributeModel? = event.attribute
        
        let data: [String: Any]?
         
         if let key = attribute?.key, let value = attribute?.value {
             data = [key: value]
         }
         else {
             data = nil
         }
         
        for system in event.systems {
             
            if let analyticsSystem = analyticsSystems[system] {
                
                let resourceAbbreviation = page.resource.abbreviation
                let pageNumber = page.page
                let screenName = resourceAbbreviation + "-" + String(pageNumber)
                
                analyticsSystem.trackMobileContentAction(
                    screenName: screenName,
                    siteSection: resourceAbbreviation,
                    action: action,
                    data: data
                )
            }
        }
    }
}
