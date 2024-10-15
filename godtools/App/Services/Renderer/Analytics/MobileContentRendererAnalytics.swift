//
//  MobileContentRendererAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentRendererAnalytics {
    
    private let analyticsSystems: [AnalyticsEvent.System: MobileContentRendererAnalyticsSystem]
        
    init(analytics: AnalyticsContainer, userAnalytics: MobileContentRendererUserAnalytics) {
        
        let analyticsSystems: [AnalyticsEvent.System: MobileContentRendererAnalyticsSystem] = [
            .appsflyer: analytics.appsFlyerAnalytics,
            .firebase: analytics.firebaseAnalytics,
            .user: userAnalytics
        ]
 
        self.analyticsSystems = analyticsSystems
    }
        
    func trackEvents(events: [AnalyticsEvent], renderedPageContext: MobileContentRenderedPageContext) {
        
        for event in events {
            if !event.shouldTrigger(state: renderedPageContext.rendererState) { continue }
            trackEvent(event: event, renderedPageContext: renderedPageContext)
            event.recordTriggered(state: renderedPageContext.rendererState)
        }
    }
    
    private func trackEvent(event: AnalyticsEvent, renderedPageContext: MobileContentRenderedPageContext) {
        
        let action = event.action
        guard !action.isEmpty else {
            return
        }
                
        let data: [String: String] = event.attributes
        let systems: [AnalyticsEvent.System] = Array(event.systems)
        
        for system in systems {
            
            guard let analyticsSystem = analyticsSystems[system] else {
                continue
            }
             
            let resourceAbbreviation = renderedPageContext.resource.abbreviation
            let pageNumber = renderedPageContext.pageModel.position
            let screenName = resourceAbbreviation + "-" + String(pageNumber)
            
            analyticsSystem.trackMobileContentAction(
                context: renderedPageContext,
                screenName: screenName,
                siteSection: resourceAbbreviation,
                action: action,
                data: data
            )
        }
    }
}
