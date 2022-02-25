//
//  MobileContentAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

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
        
    func trackEvents(events: [AnalyticsEvent], rendererPageModel: MobileContentRendererPageModel) {
        
        for event in events {
            trackEvent(event: event, rendererPageModel: rendererPageModel)
        }
    }
    
    private func trackEvent(event: AnalyticsEvent, rendererPageModel: MobileContentRendererPageModel) {
        
        guard let action = event.action, !action.isEmpty else {
            return
        }
                
        let data: [String: String] = event.attributes
        let systems: [AnalyticsEvent.System] = Array(event.systems)
        
        for system in systems {
             
            if let analyticsSystem = analyticsSystems[system.name.lowercased()] {
                
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
