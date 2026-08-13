//
//  MobileContentRendererAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

final class MobileContentRendererAnalytics: Sendable {
    
    private let analyticsSystems: [AnalyticsEvent.System: MobileContentRendererAnalyticsSystem]
        
    init(analytics: AnalyticsContainer, userAnalytics: MobileContentRendererUserAnalytics) {
        
        let analyticsSystems: [AnalyticsEvent.System: MobileContentRendererAnalyticsSystem] = [
            .firebase: analytics.firebaseAnalytics,
            .user: userAnalytics
        ]
 
        self.analyticsSystems = analyticsSystems
    }
        
    func trackEvents(events: [AnalyticsEvent], renderedPageContext: MobileContentRenderedPageContext) async throws {
        
        for event in events {
            
            let shouldTrigger: Bool = event.shouldTrigger(state: renderedPageContext.rendererState)
            
            guard shouldTrigger else {
                continue
            }
            
            try await trackEvent(event: event, renderedPageContext: renderedPageContext)
            
            event.recordTriggered(state: renderedPageContext.rendererState)
        }
    }
    
    private func trackEvent(event: AnalyticsEvent, renderedPageContext: MobileContentRenderedPageContext) async throws {
        
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
            
            try await analyticsSystem.trackMobileContentAction(
                screenName: screenName,
                siteSection: resourceAbbreviation,
                appLanguage: renderedPageContext.appLanguage,
                contentLanguage: renderedPageContext.rendererLanguages.primaryLanguage.localeId,
                secondaryContentLanguage: renderedPageContext.rendererLanguages.parallelLanguage?.localeId,
                action: action,
                data: data
            )
        }
    }
}
