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
    
    private let analyticsSystems: [AnalyticsEvent.System: MobileContentAnalyticsSystem]
        
    required init(analytics: AnalyticsContainer, userAnalytics: UserAnalytics) {
        
        let analyticsSystems: [AnalyticsEvent.System: MobileContentAnalyticsSystem] = [
            .appsflyer: analytics.appsFlyerAnalytics,
            .firebase: analytics.firebaseAnalytics,
            .user: userAnalytics
        ]
 
        self.analyticsSystems = analyticsSystems
    }
        
    func trackEvents(events: [AnalyticsEvent], renderedPageContext: MobileContentRenderedPageContext) {
        
        for event in events {
            trackEvent(event: event, renderedPageContext: renderedPageContext)
        }
    }
    
    private func trackEvent(event: AnalyticsEvent, renderedPageContext: MobileContentRenderedPageContext) {
        
        guard let action = event.action, !action.isEmpty else {
            return
        }
                
        let data: [String: String] = event.attributes
        let systems: [AnalyticsEvent.System] = Array(event.systems)
        
        for system in systems {
            
            guard let analyticsSystem = analyticsSystems[system] else {
                continue
            }
             
            let resourceAbbreviation = renderedPageContext.resource.abbreviation
            let pageNumber = renderedPageContext.page
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
