//
//  BaseTractElementDiContainer.swift
//  godtools
//

import Foundation

class BaseTractElementDiContainer {
    
    let followUpsService: FollowUpsService
    let analytics: AnalyticsContainer
    
    required init(followUpsService: FollowUpsService, analytics: AnalyticsContainer) {
        
        self.followUpsService = followUpsService
        self.analytics = analytics
    }
}
