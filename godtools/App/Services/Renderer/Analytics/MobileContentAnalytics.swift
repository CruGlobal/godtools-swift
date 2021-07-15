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
        
    func trackEvents(events: [AnalyticsEventModelType], rendererPageModel: MobileContentRendererPageModel) {
        
        for event in events {
            trackEvent(event: event, rendererPageModel: rendererPageModel)
        }
    }
    
    private func trackEvent(event: AnalyticsEventModelType, rendererPageModel: MobileContentRendererPageModel) {
        
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
                
                let resourceAbbreviation = rendererPageModel.resource.abbreviation
                let pageNumber = rendererPageModel.page
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
